defmodule ClientTest do
  use ExUnit.Case

  alias Coapex.{Client, Message}

  @host "127.0.0.1"
  @port 9999
  @uri "coap://#{@host}:#{@port}"

  test "make a request" do
    msg = Message.init(code: :get,
      options: [uri_host: @host, uri_port: 9999])
    _req = Client.request(msg)
  end

end
