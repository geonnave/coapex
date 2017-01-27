defmodule Coapex.Message do
  @moduledoc """
  The Message struct is supposed to be filled by the user,
  with user-friendly types like strings and integers; also,
  the user will probably use Message.options and Message.types
  helper functions for fulfilling the struct.
  Note that the `uri` parameter will be used to create
  specific `options` params (e.g Uri-Host, Uri-Port, etc.)
  """

  #defstruct version: <<1::2>>, TODO: why this raises an error???
  defstruct version: 1,
    code: nil,
    type: nil,
    token: nil,
    msg_id: nil,
    options: [uri_port: 5683],
    payload: ""

  def init(args) do
    options_field = Keyword.get(args, :options, [])
    options_field = Keyword.merge([uri_port: 5683], options_field)

    %Coapex.Message{
      version: 1,
      code: args[:code],
      type: args[:type],
      token: args[:token],
      msg_id: Keyword.get(args, :msg_id, random_id()),
      options: options_field,
      payload: Keyword.get(args, :payload, "")
    }
  end

  def request(method, uri, args \\ []) when is_atom(method) do
    args = put_in(args[:code], method)

    %URI{host: host, path: path, port: port, query: query,
         scheme: "coap", fragment: nil} = URI.parse(uri)

    path_segments =
      path
      |> URI.path_to_segments()
      |> Enum.reverse()
      |> Stream.reject(&(&1 == ""))
      |> Enum.map(&({:uri_path, &1}))

    query_segments = Enum.map(query || [], fn({param, value}) -> "#{param}=#{value}" end)

    uri_opts = [uri_host: host, uri_port: port] ++ path_segments ++ query_segments
    options_field =
      if args[:options] do
        Keyword.merge(args[:options], uri_opts)
      else
        uri_opts
      end

    args
    |> Keyword.put(:options, options_field)
    |> init()
  end

  def response(code, peer, args \\ []) do
    args = put_in(args[:code], code)
    # TODO
  end

  def random_id do
    System.unique_integer([:positive])
  end

  def encode(message = %Coapex.Message{}) do
    message |> Coapex.Encoder.encode
  end

  def decode(bin_message = <<_::binary>>) do
    bin_message |> Coapex.Decoder.decode
  end

end
