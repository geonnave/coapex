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
    msg = Coapex.Encoder.set_msg_id(%Message{}, 100)
  end
end
