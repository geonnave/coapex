defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder

  test "build a simple message" do
    m = Message.init([])
  end

end
