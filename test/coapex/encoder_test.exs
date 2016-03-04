defmodule EncoderTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder


  @host_option Encoder.options[:"Uri-Host"]
  @path_option Encoder.options[:"Uri-Path"]
  @port_option Encoder.options[:"Uri-Port"]

  test "Message set type works" do
    msg = Coapex.Encoder.set_type(%Message{}, :con)
    assert msg.type == <<0 :: size(2)>>
  end

  test "set Message token works" do
    msg = Coapex.Encoder.set_token(%Message{}, "abc")
    assert msg.tk_len == <<3::size(4)>>
    assert msg.token == "abc"
    msg = Coapex.Encoder.set_token(%Message{}, "")
    assert msg.tk_len == <<0::size(4)>>
    assert msg.token == <<>>
  end

  test "set Message code works" do
    msg = Coapex.Encoder.set_code(%Message{}, {2, 05})
    assert msg.code == <<2 :: size(3), 5 :: size(5)>>

    msg = Coapex.Encoder.set_code(%Message{}, "2.05")
    assert msg.code == <<2 :: size(3), 5 :: size(5)>>

    msg = Coapex.Encoder.set_code(%Message{}, 205)
    assert msg.code == <<2 :: size(3), 5 :: size(5)>>
  end
  test "set Message invalid codes raises error" do
    assert_raise RuntimeError, fn -> Coapex.Encoder.set_code(%Message{}, 123) end
    assert_raise RuntimeError, fn -> Coapex.Encoder.set_code(%Message{}, 303) end
    assert_raise RuntimeError, fn -> Coapex.Encoder.set_code(%Message{}, 666) end
    assert_raise RuntimeError, fn -> Coapex.Encoder.set_code(%Message{}, 700) end
  end

  test "set Message id works" do
    msg = Coapex.Encoder.set_msg_id(%Message{}, 1)
    assert msg.msg_id == <<1::unsigned-integer-size(16)>>
    msg = Coapex.Encoder.set_msg_id(%Message{}, 100)
    assert msg.msg_id == <<100::unsigned-integer-size(16)>>
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

  test "build Message options" do
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

  test "set Message options" do
    [delta_urihost, len_urihost] = [Encoder.options[:"Uri-Host"], String.length("foo.bar")]
    [delta_uripath, len_uripath] = [Encoder.options[:"Uri-Path"]-delta_urihost, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uripath::size(4), len_uripath::size(4), "baz">>
    msg = Coapex.Encoder.set_options(%Message{}, ["Uri-Path": "baz", "Uri-Host": "foo.bar"])
    assert expected == msg.options
  end

  test "set Message payload" do
    msg = Coapex.Encoder.set_payload(%Message{}, "abc")
    assert "abc" == msg.payload
    msg = Coapex.Encoder.set_payload(%Message{}, 123)
    assert <<123>> == msg.payload
  end

  test "encode Coap Message" do
    msg = Encoder.build_msg({:con, "", "0.01", 11, ["Uri-Path": "baz", "Uri-Host": "foo.bar"], "abc"})
    assert msg.payload == "abc"

    ver = <<1::size(2)>>
    type = <<Encoder.types[:con]::size(2)>>
    tk_len = <<0::size(4)>>
    code = <<0::size(3), 1::size(5)>>
    msg_id = <<11::size(16)>>
    token = <<>>
    options = Coapex.Encoder.build_options [{@host_option, "foo.bar"}, {@path_option, "baz"}]
    payload = "abc"
    expected_msg = <<ver::bitstring, type::bitstring, tk_len::bitstring, code::bitstring,
                 msg_id::bitstring, token::bitstring, options::bitstring, 0xFF, payload::bitstring>>

    bin_msg = Encoder.encode(msg)
    assert expected_msg == bin_msg
  end
end
