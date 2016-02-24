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

  use Bitwise

  @types [con: 0, non: 1, ack: 2, rst: 3]
  @options [
    "If-Match":        1,
    "Uri-Host":        3,
    "ETag":            4,
    "If-None-Match":   5,
    "Uri-Port":        7,
    "Location-Path":   8,
    "Uri-Path":       11,
    "Content-Format": 12,
    "Max-Age":        14,
    "Uri-Query":      15,
    "Accept":         17,
    "Location-Query": 20,
    "Proxy-Uri":      35,
    "Proxy-Scheme":   39,
    "Size1":          60
  ]

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
    options = Enum.sort(options, fn({o1, _v1}, {o2, _v2}) -> @options[o1] < @options[o2] end)
  end

  def build_options(options), do: build_options(options, 0)
  def build_options([], _prev_num), do: <<>>
  def build_options(options = [opt = {op, value} | rest], prev_num) do
    delta = @options[op] - prev_num
    build_binary_option(delta, value) <> build_options(rest, delta)
  end

  def build_binary_option(delta, value) do
    binary_value = value_to_binary(value)
    build_binary_option_header(delta, String.length(binary_value)) <> binary_value
  end

  def build_binary_option_header(delta, opt_len) do
    case delta do
      delta when delta in 0..12 ->
        <<delta::unsigned-integer-size(4),
          opt_len::unsigned-integer-size(4)>>
      delta ->
        raise "Not implemented yet"
    end
  end

  def value_to_binary(value) when is_binary(value), do: <<value::binary>>
  def value_to_binary(value) when is_number(value) do
    cond do
      value < 0 ->
        raise "invalid value"
      value > (2 <<< 32) ->
        raise "invalid value"
      true ->
        number_to_binary(value)
    end
  end

  def number_to_binary(number), do: number_to_binary(number, 0)
  def number_to_binary(number, 32), do: <<(number &&& 0xFF)>>
  def number_to_binary(0, _shift), do: <<>>
  def number_to_binary(number, shift) do
    <<(number &&& 0xFF)>> <> number_to_binary(number >>> shift+8, shift+8)
  end

end
