defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder
  alias Coapex.Client

  test "build a simple message" do
    m = Message.init(:request, [code: :get, uri_host: "example.com", options: ["Accept": "application/json"]])
    assert %Message{code: :get, uri_host: "example.com"} = m
  end

end
