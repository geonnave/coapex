defmodule Coapex.Client do

  def request(_method, _target_url, opts \\ [type: :con])
  def request(:get, target_uri, opts) do
    opts[:options] = case opt[:options] do
      nil ->
        uri_to_options(target_uri)
      options ->
        options ++ uri_to_options(target_uri)
    end
    message = Coapex.Message.init(:get, target_uri, opts)
    message |> IO.inspect
    # resp = message |> build_binary |> send
  end
  def request(:post, target_uri, opts) do
    message = Coapex.Message.init(:post, target_uri, opts)
    # resp = message |> build_binary |> send
  end

  def uri_to_options(uri) do
    uri = URI.parse(uri)
    # DOUBT: where the information for `coap` or `coaps` goes?
    # (there is no `scheme` option)
    [uri_host: uri.host, uri_port: uri.port, uri_path: uri.path, uri_query: uri.query]
  end

end
