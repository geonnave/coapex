defmodule EncoderTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder

  test "Message set type works" do
    msg = Coapex.Encoder.set_type(%Message{}, :con)
    assert msg.type == <<0 :: size(2)>>
  end

  test "set Message token works" do
    msg = Coapex.Encoder.set_token(%Message{}, "abc")
    assert msg.tk_len == 3
    assert msg.token == "abc"
    msg = Coapex.Encoder.set_token(%Message{}, "")
    assert msg.tk_len == 0
    assert msg.token == nil
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

  test "build Message option" do
    expected = <<3::size(4), 7::size(4), "foo.bar"::binary>>
    assert expected == Coapex.Encoder.build_binary_option 3, "foo.bar"

    expected = <<7::size(4), 1::size(4), 11::unsigned-integer>>
    assert expected == Coapex.Encoder.build_binary_option 7, 11

    expected = <<7::size(4), 2::size(4), 0::unsigned-integer, 1::unsigned-integer>>
    assert expected == Coapex.Encoder.build_binary_option 7, 256
  end

  test "build option delta" do
    assert {:simple, <<(11-3)::size(4)>>} == Encoder.gen_option_header(11-3)
    assert {:extra, {<<13::size(4)>>, <<(60-15-13)::size(8)>>}} == Encoder.gen_option_header(60-15)
    assert {:extra, {<<14::size(4)>>, <<(600-15-269)::size(16)>>}} == Encoder.gen_option_header(600-15)
  end

  test "build Message options" do
    [delta_urihost, len_urihost] = [Encoder.options[:"Uri-Host"], String.length("foo.bar")]
    [delta_uripath, len_uripath] = [Encoder.options[:"Uri-Path"]-delta_urihost, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uripath::size(4), len_uripath::size(4), "baz">>
    opts = Coapex.Encoder.build_options ["Uri-Host": "foo.bar", "Uri-Path": "baz"]
    assert expected == opts

    [delta_urihost, len_urihost] = [Encoder.options[:"Uri-Host"], String.length("foo.bar")]
    [delta_uriport, len_uriport] = [Encoder.options[:"Uri-Port"]-delta_urihost, 1]
    [delta_uripath, len_uripath] = [Encoder.options[:"Uri-Path"]-delta_uriport, String.length("baz")]
    expected = <<delta_urihost::size(4), len_urihost::size(4), "foo.bar",
                 delta_uriport::size(4), len_uriport::size(4), 88,
                 delta_uripath::size(4), len_uripath::size(4), "baz">>
    opts = Coapex.Encoder.build_options ["Uri-Host": "foo.bar", "Uri-Port": 88, "Uri-Path": "baz"]
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
end
