defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message

  test "init a simple message" do
    msg = Message.init(code: :get,
                     options: [uri_host: "example.com", accept: :"application/json"])
    assert %Message{code: :get, options: [uri_host: "example.com", accept: :"application/json"]} == msg
  end

  test "init, encode and decode a simple message" do
    msg = Message.init(type: :con, code: :get, msg_id: 123,
                     options: [uri_host: "example.com", accept: :"application/json"])
    bin_msg = Message.encode(msg)
    assert msg == Message.decode(bin_msg)

    msg = Message.init(type: :con, code: :get, msg_id: 123,
      options: [uri_host: "example.com", uri_port: 9999, uri_path: "foo", accept: :"application/json"])
    bin_msg = Message.encode(msg)
    assert msg == Message.decode(bin_msg)
  end

end
