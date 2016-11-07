defmodule Coapex.Server do
  use GenServer
  require Logger

  alias Coapex.{Message, Encoder, Decoder}

  @default_port 9998
  @default_router Coapex.DefaultRouter

  @error_500 Message.init(code: :internal_server_error, type: :ack, msg_id: 1)

  def start_link(opts \\ [router: @default_router]) do
    GenServer.start_link(__MODULE__, opts[:router], name: __MODULE__)
  end

  def delegate(non_conn, router) do
    msg = non_conn[:msg]
    path = Keyword.get_values(msg.options, :uri_path)
    router.match(msg.code, path, non_conn)
  end

  def reply_con(non_conn, code, payload) do
    msg = %Coapex.Message{non_conn[:msg] | payload: payload, code: code, type: :ack}
    Logger.debug "=>> #{inspect msg}"
    GenServer.cast __MODULE__, {:reply_con, %{non_conn | msg: msg}}
  end

  # GenServer callbacks
  def init(router) do
    {:ok, socket} = :gen_udp.open(@default_port, [:binary])
    {:ok, %{socket: socket, router: router}}
  end

  def handle_info(_msg = {:udp, socket, ip, port, data}, state) do
    try do
      in_msg = Decoder.decode(data)
      Logger.debug "<<= #{inspect in_msg}"
      if !state.router do
        out_msg = @error_500 |> Encoder.encode
        Logger.error "=>> #{inspect out_msg}"
        :gen_udp.send(socket, ip, port, out_msg)
      else
        non_conn = %{udp: {socket, ip, port}, owner: self(), msg: in_msg}
        Task.start(fn -> delegate(non_conn, state.router) end)
      end
    rescue
      e ->
        Logger.error(inspect e)
        out_msg = @error_500 |> Encoder.encode
        Logger.error "=>> #{inspect out_msg}"
        :gen_udp.send(socket, ip, port, out_msg)
    end
    {:noreply, state}
  end

  def handle_cast({:reply_con, non_conn}, state) do
    bin_msg = Coapex.Encoder.encode(non_conn[:msg])
    {sock, ip, port} = non_conn[:udp]
    :gen_udp.send(sock, ip, port, bin_msg)
    {:noreply, state}
  end
end

defmodule Coapex.DefaultRouter do
  require Logger
  import Coapex.Server, only: [reply_con: 3]

  def match(:get, path, non_conn) do
    if non_conn[:msg].type == :con do
      reply_con(non_conn, "2.05", "was a get! on path #{path |> inspect}")
    end
  end
  def match(:post, path, non_conn) do
    if non_conn[:msg].type == :con do
      reply_con(non_conn, "2.05", "was a post! on path #{path |> inspect}")
    end
  end
  def match(method, path, non_conn) do
    if non_conn[:msg].type == :con do
      reply_con(non_conn, "2.05", "was other method: #{method |> inspect} on path #{path |> inspect}")
    end
  end
end
