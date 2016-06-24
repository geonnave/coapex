defmodule Coapex.Client do

  def request(_method, _target_url, opts \\ [type: :con])
  def request(:get, target_uri, opts) do
    message = Coapex.Message.init(:get, target_uri, opts)
    message |> IO.inspect
    # resp = message |> build_binary |> send
  end
  def request(:post, target_uri, opts) do
    message = Coapex.Message.init(:post, target_uri, opts)
    # resp = message |> build_binary |> send
  end

end
