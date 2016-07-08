defmodule Coapex.Server do
  use GenServer

  alias Coapex.{Message}

  @port 9999

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(@port, [:binary])
  end

  def handle_info({:udp, socket, ip, port, data}, state) do
    IO.inspect [ip, port, data]
    :gen_udp.send(socket, ip, port, "I'm here!\n")
    {:noreply, state}
  end

end
