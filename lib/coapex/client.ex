defmodule Coapex.Client do
  alias Coapex.{Message, Encoder, Decoder}

  @host_erl {127,0,0,1}
  @port 9999

  def do_request_sync(msg) do
    bin_msg = Encoder.encode(msg)

    {:ok, sock} = :gen_udp.open 0, [:binary]

    :gen_udp.send(sock, @host_erl, @port, bin_msg)

    resp_msg = receive do
      {:udp, socket, ip, port, data} ->
        data |> Decoder.decode
    after
      1000 -> :timeout |> IO.inspect
    end
  end

  # we don't use these functions yet
  def request(_method, _target_url, opts \\ [type: :con, options: []])

  def request(:get, target_uri, opts) do
    opts = put_in(opts[:options], set_options_uri(opts[:options], target_uri))
    opts = Keyword.merge(opts, [msg_id: :crypto.strong_rand_bytes(2), code: :get])
    Message.init(opts)
  end

  def set_options_uri(options, uri) do
    uri = URI.parse(uri)
    # DOUBT: where does the information for `coap` or `coaps` go?
    # (there is no `scheme` option)
    Keyword.merge(options,
                  [uri_host: uri.host, uri_port: uri.port,
                   uri_path: uri.path, uri_query: uri.query])
  end

end
