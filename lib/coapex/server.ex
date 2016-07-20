defmodule Coapex.Server do
  use GenServer

  alias Coapex.{Message, Encoder, Decoder}

  @port 9998

  @error_500 Message.init(code: :internal_server_error, type: :ack, msg_id: 1,
    options: [uri_host: @host, uri_port: @port])

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:router], name: __MODULE__)
  end

  def init(router) do
    {:ok, socket} = :gen_udp.open(@port, [:binary])
    {:ok, %{socket: socket, router: router}}
  end

  def handle_info(_msg = {:udp, socket, ip, port, data}, state) do
    try do
      "====new message====" |> IO.inspect
      data |> IO.inspect
      in_msg = Decoder.decode(data) |> IO.inspect
      if !state.router do
        out_msg = %Message{in_msg | code: :internal_server_error} |> Encoder.encode
        :gen_udp.send(socket, ip, port, out_msg)
      else
        data = [udp_params: {socket, ip, port}, msg: in_msg]
#       spawn(fn -> router.delegate(data) end)
        state.router.delegate(data)
        IO.inspect "TEST"
      end
    rescue
      e ->
        IO.inspect e
        out_msg = @error_500 |> Encoder.encode
        :gen_udp.send(socket, ip, port, out_msg)
    end
    {:noreply, state}
  end

end
