defmodule ServerTest do
  use ExUnit.Case

  alias Coapex.{Message, Encoder, Decoder, Registry, Server, Client}

  @host "127.0.0.1"
  @port 9998

  setup do
    Server.start_link
    :ok
  end

  test "server with RouterA" do
    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg)

    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, uri_path: "foo/bar", accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg)

    msg = Message.init(code: :post, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg)
  end

end
