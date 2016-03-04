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

  def options, do: @options

  def build_msg({type, token, code, msg_id, options, payload}) do
    %Message{version: <<1 :: size(2)>>}
    |> set_type(type)
    |> set_token(token)
    |> set_code(code)
    |> set_msg_id(msg_id)
    |> set_options(options)
    |> set_payload(payload)
  end

  def encode(msg = {_type, _token, _code, _msg_id, _options, _payload}) do
    msg |> build_msg |> encode
  end
  def encode(msg = %Message{}) do
    IO.inspect msg
    <<(msg.version)::bitstring, (msg.type)::bitstring, (msg.tk_len)::bitstring, msg.code,
      msg.msg_id, msg.options, 0xFF, msg.payload>>
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
  def set_code(msg, << class, ".", detail :: binary>>) do
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
  def set_msg_id(_msg, _id), do: raise "Invalid id"

  def set_payload(msg, payload) when is_binary(payload) do
    %Message{msg | payload: payload}
  end
  def set_payload(msg, payload), do: set_payload(msg, value_to_binary(payload))

  @doc """
  Each option instance in a message specifies the Option Number of the
    defined CoAP option, the length of the Option Value, and the Option
    Value itself.
  """
  def set_options(msg, options) do
    options =
      options
      |> Stream.map(fn({o, v}) ->
          cond do
            is_atom(o) and @options[o] -> {@options[o], v}
            is_integer(o) -> {o, v}
            true -> nil
          end
        end)
      |> Stream.reject(&is_nil/1)
      |> Enum.sort(fn({o1, _v1}, {o2, _v2}) -> o1 < o2 end)
    %Message{msg | options: build_options(options)}
  end

  @doc """
  Encode options as binary fields, recursively.

  Each option is a binary chunk as below represented:
  0   1   2   3   4   5   6   7
  +---------------+---------------+
  |               |               |
  |  Option Delta | Option Length |   1 byte
  |               |               |
  +---------------+---------------+
  \                               \
  /         Option Delta          /   0-2 bytes
  \          (extended)           \
  +-------------------------------+
  \                               \
  /         Option Length         /   0-2 bytes
  \          (extended)           \
  +-------------------------------+
  \                               \
  /                               /
  \                               \
  /         Option Value          /   0 or more bytes
  \                               \
  /                               /
  \                               \
  +-------------------------------+

  Figure 8: Option Format (taken from RFC7252)
  """
  def build_options(options), do: build_options(options, 0)
  def build_options([], _prev_delta), do: <<>>
  def build_options([{op, value} | rest], prev_delta) do
    delta = op - prev_delta

    value = value_to_binary(value)

    {del, ext_del} = gen_option_header(delta)
    {len, ext_len} = gen_option_header(String.length(value))

    <<del::bitstring, len::bitstring,
      ext_del::bitstring, ext_len::bitstring, value::bitstring>> <> build_options(rest, delta)
  end

  @doc """
  from RFC7252:
    Option Delta:  4-bit unsigned integer.  A value between 0 and 12
    indicates the Option Delta.  Three values are reserved for special
    constructs:

    13:  An 8-bit unsigned integer follows the initial byte and
    indicates the Option Delta minus 13.

    14:  A 16-bit unsigned integer in network byte order follows the
    initial byte and indicates the Option Delta minus 269.

    15:  Reserved for the Payload Marker.  If the field is set to this
    value but the entire byte is not the payload marker, this MUST
    be processed as a message format error.

  The same rules apply for building the Option Length field. Thus, the
   function below is useful for generating both Delta and Length fields.
  """
  def gen_option_header(value) when value in 0..12, do: {<<value::unsigned-integer-size(4)>>, <<>>}
  def gen_option_header(value) when value > 12 and value <= 255 do
    {<<13::unsigned-integer-size(4)>>, <<(value-13)::unsigned-integer-size(8)>>}
  end
  def gen_option_header(value) when value > 255 and value < (2 <<< 16) do
    {<<14::unsigned-integer-size(4)>>, <<(value-269)::unsigned-integer-size(16)>>}
  end
  def gen_option_header(_), do: raise "Invalid value"

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
