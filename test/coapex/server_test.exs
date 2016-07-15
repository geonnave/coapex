defmodule ServerTest do
  use ExUnit.Case

  alias Coapex.{Message, Encoder, Decoder, Registry, Server}

  @host "127.0.0.1"
  @host_erl {127,0,0,1}
  @port 9999

  setup do
    Server.start_link
    :ok
  end

  test "echo socket server" do
    msg = Message.init(code: :get, type: :con, msg_id: 1, payload: "swarm!",
      options: [uri_host: @host, uri_port: @port, accept: :"text/plain;", content_format: :"text/plain;"])

    bin_msg = Encoder.encode(msg)

    {:ok, sock} = :gen_udp.open 0, [:binary]
    :gen_udp.send(sock, @host_erl, @port, bin_msg)

    resp_msg = receive do
      {:udp, socket, ip, port, data} ->
        data
    after
      1000 -> :timeout |> IO.inspect
    end

    assert msg = Decoder.decode(resp_msg)

  end
end
