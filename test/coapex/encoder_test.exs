defmodule EncoderTest do
  use ExUnit.Case

  alias Coapex.Message

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

  test "build Message option" do
    assert <<3::size(4), 7::size(4), "foo.bar"::binary>> == Coapex.Encoder.build_binary_option 3, "foo.bar"
  end
  test "build Message options" do
    opts = Coapex.Encoder.build_options ["Uri-Host": "foo.bar", "Uri-Path": "baz"]
    IO.inspect opts
  end
  test "set Message options" do
    msg = Coapex.Encoder.set_options(%Message{}, ["Uri-Path": "baz", "Uri-Host": "foo.bar"])
  end
end
