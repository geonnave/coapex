defmodule EncoderTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder


  @host_option Message.options[:"Uri-Host"]
  @path_option Message.options[:"Uri-Path"]
  @port_option Message.options[:"Uri-Port"]

  test "encode type works" do
    assert <<0 :: size(2)>> == Encoder.encode_type(:con)
  end

  test "encode token works" do
    assert {"abc", <<3::size(4)>>} == Encoder.encode_token("abc")
    assert {"", <<0::size(4)>>} == Encoder.encode_token("")
  end

  test "encode code works" do
    assert <<2::size(3), 5::size(5)>> == Encoder.encode_code({2, 05})
    assert <<2::size(3), 5::size(5)>> == Encoder.encode_code("2.05")
    assert <<2::size(3), 5::size(5)>> == Encoder.encode_code(205)
  end
  test "encode invalid codes raises error" do
    assert_raise RuntimeError, fn -> Encoder.encode_code(123) end
    assert_raise RuntimeError, fn -> Encoder.encode_code(303) end
    assert_raise RuntimeError, fn -> Encoder.encode_code(666) end
    assert_raise RuntimeError, fn -> Encoder.encode_code(700) end
  end

  test "encode msg id works" do
    assert <<1::unsigned-integer-size(16)>> == Encoder.encode_msg_id(1)
    assert <<100::unsigned-integer-size(16)>> == Encoder.encode_msg_id(100)
  end

  test "encode payload" do
    assert "abc" == Encoder.encode_payload("abc")
    assert <<123>> == Encoder.encode_payload(123)
  end

  # Now testing options stuff!
  test "number to binary" do
    assert Coapex.Encoder.number_to_binary(3) == <<3>>
    assert Coapex.Encoder.number_to_binary(255) == <<255>>
    assert Coapex.Encoder.number_to_binary(256) == <<0, 1>>
    assert Coapex.Encoder.number_to_binary(257) == <<1, 1>>
  end
  test "integer value to binary" do
    assert Coapex.Encoder.value_to_binary(3) == <<3>>
    assert Coapex.Encoder.value_to_binary("a") == <<97>>
  end

  test "build option delta" do
    assert {<<(11-3)::size(4)>>, <<>>} == Encoder.gen_option_header(11-3)
    assert {<<13::size(4)>>, <<(60-15-13)::size(8)>>} == Encoder.gen_option_header(60-15)
    assert {<<14::size(4)>>, <<(600-15-269)::size(16)>>} == Encoder.gen_option_header(600-15)
  end

  test "build options" do
    [delta_urihost, len_urihost] = [@host_option, String.length("foo.bar")]
    [delta_uripath, len_uripath] = [@path_option-delta_urihost, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uripath::size(4), len_uripath::size(4), "baz">>
    opts = Coapex.Encoder.build_options [{@host_option, "foo.bar"}, {@path_option, "baz"}]
    assert expected == opts

    [delta_urihost, len_urihost] = [@host_option, String.length("foo.bar")]
    [delta_uriport, len_uriport] = [@port_option-delta_urihost, 1]
    [delta_uripath, len_uripath] = [@path_option-delta_uriport, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uriport::size(4), len_uriport::size(4), 88,
                 delta_uripath::size(4), len_uripath::size(4), "baz">>
    opts = Coapex.Encoder.build_options [{@host_option, "foo.bar"}, {@port_option, 88}, {@path_option, "baz"}]
    assert expected == opts
  end

  test "set BinaryMessage options" do
    [delta_urihost, len_urihost] = [Message.options[:"Uri-Host"], String.length("foo.bar")]
    [delta_uripath, len_uripath] = [Message.options[:"Uri-Path"]-delta_urihost, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uripath::size(4), len_uripath::size(4), "baz">>

    assert expected == Encoder.encode_options(["Uri-Path": "baz", "Uri-Host": "foo.bar"])
  end

  test "encode Coap Message" do
    msg = %Message{type: :con, token: <<>>, code: "0.01", msg_id: 11,
                   options: ["Uri-Path": "baz", "Uri-Host": "foo.bar"],
                   payload: "abc"}

    expected_msg =
      <<Message.version::bitstring,
        Message.types[:con]::size(2), # type CON is 0
        0::size(4),                   # token length is 0
        0::size(3), 1::size(5),       # code is 0.01
        11::size(16),                 # message id is 11
        <<>>,                         # token (empty)
        Encoder.build_options([{@host_option, "foo.bar"}, {@path_option, "baz"}])::bitstring,
        0xFF,                         # payload marker
        "abc">>                       # payload

    bin_msg = Encoder.encode(msg)
    assert expected_msg == bin_msg
  end
end
