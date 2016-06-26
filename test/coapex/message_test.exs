defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Encoder
  alias Coapex.Client

  test "init a simple message" do
    m = Message.init(:request, [code: :get, uri_host: "example.com", options: [accept: "application/json"]])
    assert %Message{code: :get, uri_host: "example.com"} = m
  end

  test "init and encode a simple message" do
    m = Message.init(:request,
                     type: :con, code: :get, msg_id: 123,
                     uri_host: "example.com",
                     options: [accept: "application/json"])
    encoded_m = Message.encode(:request, m)
    IO.inspect encoded_m
  end

end
