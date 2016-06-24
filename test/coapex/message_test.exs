defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder

  test "build a simple message" do
    m = Message.init(:request, :get, "coap://example.com", type: :con, options: ["Accept": "application/json"])
    IO.inspect m
  end

end
