defmodule Coapex.Server do
  use GenServer

  alias Coapex.{Message, Encoder, Decoder}

  @port 9999

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(@port, [:binary])
  end

  def handle_info(_msg = {:udp, socket, ip, port, data}, state) do
    try do
      in_msg = Decoder.decode(data)
      :gen_udp.send(socket, ip, port, data)
    rescue
      _ -> :gen_udp.send(socket, ip, port, "5.00 No!\n")
    end
    {:noreply, state}
  end

end
