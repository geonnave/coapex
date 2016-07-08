defmodule Coapex.Client do
  alias Coapex.{Message}

  def request(msg) do
    msg
  end

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
