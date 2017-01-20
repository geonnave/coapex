defmodule MessageTest do
  use ExUnit.Case

  alias Coapex.Message

  test "init an empty message" do
    msg = Message.init(code: :get)
    assert %Message{code: :get, options: [uri_port: 5683]} = msg
  end

  test "init a simple message" do
    msg = Message.init(code: :get,
                     options: [uri_host: "example.com", accept: :"application/json"])
    assert %Message{code: :get, options: [uri_port: 5683, uri_host: "example.com",
                                          accept: :"application/json"]} = msg
  end

  test "init, encode and decode a simple message" do
    msg = Message.init(type: :con, code: :get, msg_id: 123,
                     options: [uri_host: "example.com", accept: :"application/json"])
    bin_msg = Message.encode(msg)
    assert msg = Message.decode(bin_msg)

    msg = Message.init(type: :con, code: :get, msg_id: 123,
      options: [uri_host: "example.com", uri_port: 9999, uri_path: "foo", accept: :"application/json"])
    bin_msg = Message.encode(msg)
    assert msg == Message.decode(bin_msg)
  end

  test "create a request" do
    req = Message.request(:get, "coap://192.168.2.192:5000/broker/registry")
    assert %Message{code: :get} = req
    assert "192.168.2.192" = req.options[:uri_host]
    assert 5000 = req.options[:uri_port]
    assert ["broker", "registry"] = Keyword.get_values(req.options, :uri_path)
  end
end
