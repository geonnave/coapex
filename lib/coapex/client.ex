defmodule Coapex.Client do

  def request(:get, target_url) do
    message = Coapex.Message.init([type: :get, url: target_url])
    # resp = message |> build_binary |> send
  end

  def request(:get, target_url) do
    message = Coapex.Message.init([type: :get, url: target_url])
    # resp = message |> build_binary |> send
  end

end
