defmodule Coapex.Message do
  defstruct [
    version: nil ,# TODO: why this doesnt work: <<1 :: size(2)>>,
    type: nil,
    tk_len: nil,
    code: nil,
    msg_id: nil,
    token: nil,
    options: nil,
    payload: nil
  ]
end

defmodule Coapex.Encoder do
  alias Coapex.Message

  @types [con: 0, non: 1, ack: 2, rst: 3]

  def encode({type, token, msg_id, options, payload}) do
    %Message{version: <<1 :: size(2)>>}
    |> set_type(type)
    |> set_token(token)
  end

  def set_type(msg, type) do
    %Message{msg | type: <<@types[type] :: size(2)>>}
  end

  def set_token(msg, <<>>), do: %Message{msg | tk_len: 0 }
  def set_token(msg, token) when is_binary(token) do
    len = String.length(token)
    %Message{msg | tk_len: len, token: token }
  end
  def set_token(msg, _token), do: msg

end
