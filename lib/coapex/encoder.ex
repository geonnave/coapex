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

  def encode({type, token, code, msg_id, options, payload}) do
    %Message{version: <<1 :: size(2)>>}
    |> set_type(type)
    |> set_token(token)
    |> set_code(code)
    |> set_msg_id(msg_id)
  end

  @doc """
  Type: 2-bit unsigned integer.  Indicates if this message is of
    type Confirmable (0), Non-confirmable (1), Acknowledgement (2), or
    Reset (3).
  """
  def set_type(msg, type) do
    %Message{msg | type: <<@types[type] :: size(2)>>}
  end

  @doc """
  The Token is used to match a response with a request.  The token
    value is a sequence of 0 to 8 bytes.
  """
  def set_token(msg, <<>>), do: %Message{msg | tk_len: 0 }
  def set_token(msg, token) when is_binary(token) do
    len = String.length(token)
    %Message{msg | tk_len: len, token: token }
  end
  def set_token(msg, _token), do: msg

  @doc """
  Code: 8-bit unsigned integer, split into a 3-bit class (most
    significant bits) and a 5-bit detail (least significant bits),
    In case of a request, the Code field indicates the Request Method;
    in case of a response, a Response Code.
  """
  def set_code(msg, code) when is_integer(code) do
    set_code(msg, {div(code, 100), rem(code, 100)})
  end
  def set_code(msg, << class, ".", detail :: binary>> = code) do
    set_code(msg, {class-48, String.to_integer(detail)})
  end
  def set_code(msg, {class, detail}) when class in [0, 2, 4, 5] do
    %Message{msg | code: <<class :: size(3), detail :: size(5)>>}
  end
  def set_code(_msg, _code), do: raise "Invalid code"

  @doc """
  Message ID: 16-bit unsigned integer in network byte order.
  """
  def set_msg_id(msg, id) when id > 0 do
    %Message{msg | msg_id: <<id::unsigned-integer-size(16)>>}
  end
  def set_msg_id(_msg, _id), do: raise "Invalid id: #{_id}"

  @doc """
  Each option instance in a message specifies the Option Number of the
    defined CoAP option, the length of the Option Value, and the Option
    Value itself.
  """
  def set_options(msg, options) do
  end

end
