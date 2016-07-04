defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message

  test "init a simple message" do
    m = Message.init(:request, code: :get,
                     options: [uri_host: "example.com", accept: "application/json"])
    assert %Message{code: :get, options: [uri_host: "example.com", accept: "application/json"]} = m
  end

  test "init and encode a simple message" do
    m = Message.init(:request,
                     type: :con, code: :get, msg_id: 123,
                     options: [uri_host: "example.com", accept: "application/json"])
    Message.encode(m, :request)
  end

end
