defmodule Coapex.Client do

  def request(_method, _target_url, opts \\ [type: :con])
  def request(:get, target_uri, opts) do
    opts =
      opts ++
      split_uri(target_uri) ++ [
      msg_id: :crypto.strong_rand_bytes(2),
      code: :get
    ]
    message = Coapex.Message.init(opts)
    message |> IO.inspect
    # resp = message |> build_binary |> send
  end
  def request(:post, target_uri, opts) do
    message = Coapex.Message.init(:post, target_uri, opts)
    # resp = message |> build_binary |> send
  end

  def split_uri(uri) do
    uri = URI.parse(uri)
    # DOUBT: where the information for `coap` or `coaps` goes?
    # (there is no `scheme` option)
    [uri_host: uri.host, uri_port: uri.port, uri_path: uri.path, uri_query: uri.query]
  end

end
