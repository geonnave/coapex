defmodule ClientTest do
  use ExUnit.Case

  alias Coapex.{Server, Client, Message}

  @host "127.0.0.1"
  @port 9999
  @uri "coap://#{@host}:#{@port}"

  setup do
    Server.start_link
    :ok
  end

  test "make a request" do
    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])
    #_req = Client.do_request_sync(msg)
  end

end
