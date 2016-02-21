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
    #msg = Coapex.Encoder.set_code(%Message{}, "")
  end
end
