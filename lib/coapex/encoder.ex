defmodule Coapex.Encoder do
  alias Coapex.Message
  alias Coapex.Values

  use Bitwise

  @doc """
  Transforms a Message struct into a binary Coap Message.

  The Message struct is built by the user. It must then be transformed into a
   binary chunk, according to RFC7252, which specifies the Coap Message Format.

  The output of this function is meant to be transmitted down to peers via UDP.
  """
  def encode(%{version: v, type: t, code: c, token: tk, msg_id: id, options: opts, payload: p}) do
    {token, tk_len} = encode_token(tk)
    <<v::bitstring, encode_type(t)::bitstring,
      tk_len::bitstring, encode_code(c)::bitstring,
      encode_msg_id(id)::bitstring, token::bitstring,
      encode_options(opts)::bitstring, 0xFF, encode_payload(p)::bitstring>>
  end

  @doc """
  Type: 2-bit unsigned integer.  Indicates if this message is of
    type Confirmable (0), Non-confirmable (1), Acknowledgement (2), or
    Reset (3).
  """
  def encode_type(type), do: <<Values.types[type] :: size(2)>>

  @doc """
  The Token is used to match a response with a request.  The token
    value is a sequence of 0 to 8 bytes.
  """
  def encode_token(<<>>), do: {<<>>, <<0::unsigned-integer-size(4)>>}
  def encode_token(token) when is_binary(token) do
    {token, <<String.length(token)::unsigned-integer-size(4)>>}
  end

  @doc """
  Code: 8-bit unsigned integer, split into a 3-bit class (most
    significant bits) and a 5-bit detail (least significant bits),
    In case of a request, the Code field indicates the Request Method;
    in case of a response, a Response Code.
  """
  def encode_code(code) when is_integer(code) do
    encode_code({div(code, 100), rem(code, 100)})
  end
  def encode_code(<< class, ".", detail :: binary>>) do
    encode_code({class-48, String.to_integer(detail)})
  end
  def encode_code({class, detail}) when class in [0, 2, 4, 5] do
    <<class :: size(3), detail :: size(5)>>
  end

  @doc """
  BinaryMessage ID: 16-bit unsigned integer in network byte order.
  """
  def encode_msg_id(id) when id > 0 and id < (1 <<< 16) do
    <<id::unsigned-integer-size(16)>>
  end

  def encode_payload(payload) when is_binary(payload), do: payload
  def encode_payload(payload), do: encode_payload(value_to_binary(payload))

  @doc """
  Each option instance in a message specifies the Option Number of the
    defined CoAP option, the length of the Option Value, and the Option
    Value itself.
  """
  def encode_options(options) do
    options
    |> Stream.map(fn({o, v}) ->
      cond do
        is_atom(o) and Values.options[o] -> {Values.options[o], v}
        is_integer(o) -> {o, v}
        true -> nil
      end
    end)
    |> Stream.reject(&is_nil/1)
    |> Enum.sort(fn({o1, _v1}, {o2, _v2}) -> o1 < o2 end)
    |> build_options
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
  def gen_option_header(value) when value > 255 and value < (1 <<< 16) do
    {<<14::unsigned-integer-size(4)>>, <<(value-269)::unsigned-integer-size(16)>>}
  end

  def value_to_binary(value) when is_binary(value), do: <<value::binary>>
  def value_to_binary(value) when is_number(value) do
    cond do
      value < 0 ->
        raise "invalid value"
      value > (1 <<< 32) ->
        raise "invalid value"
      true ->
        number_to_binary(value)
    end
  end

  def number_to_binary(number), do: number_to_binary(number, 0)
  def number_to_binary(number, 32), do: <<(number &&& 0xFF)>>
  def number_to_binary(0, _shift), do: <<>>
  def number_to_binary(number, shift) do
    <<(number &&& 0xFF)>> <> number_to_binary(number >>> (shift+8), shift+8)
  end

end
