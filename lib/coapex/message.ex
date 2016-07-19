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
    payload: nil

  def init(opts) do
    # TODO: validate all content in `opts`
    %Coapex.Message{
      version: 1,
      code: opts[:code],
      type: opts[:type],
      token: opts[:token],
      msg_id: opts[:msg_id],
      options: opts[:options],
      payload: opts[:payload]
    }
  end

  def encode(message = %Coapex.Message{}) do
    message |> Coapex.Encoder.encode
  end

  def decode(bin_message = <<_::binary>>) do
    bin_message |> Coapex.Decoder.decode
  end

end
