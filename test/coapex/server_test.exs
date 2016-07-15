defmodule ServerTest do
  use ExUnit.Case

  alias Coapex.{Message, Encoder, Decoder, Registry, Server, Client}

  @host "127.0.0.1"
  @port 9998

  defmodule RouterA do
    def send_resp(data, code, payload) do
      {sock, ip, port} = data[:udp_params]
      msg = data[:msg]
      msg = %Coapex.Message{msg | payload: payload}
      bin_msg = Coapex.Encoder.encode(msg)
      :gen_udp.send(sock, ip, port, bin_msg)
    end

    def delegate(data) do
      # TODO: implement match logic
      msg = data[:msg]
      path = if m = msg.options[:uri_path], do: m |> URI.path_to_segments, else: ""
      match(msg.code, path, data)
    end

    def match(:get, path, data) do
      send_resp(data, "2.05", "was a get! on path #{path |> inspect}")
    end
    def match(:post, path, data) do
      send_resp(data, "2.05", "was a post! on path #{path |> inspect}")
    end
    def match(method, path, data) do
      send_resp(data, "2.05", "was other method: #{method |> inspect} on path #{path |> inspect}")
    end
  end

  setup do
    Server.start_link([router: RouterA])
    :ok
  end

  test "server with RouterA" do
    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg) |> IO.inspect

    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, uri_path: "foo/bar", accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg) |> IO.inspect

    msg = Message.init(code: :post, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])
    resp = Client.do_request_sync(msg) |> IO.inspect
  end

end
