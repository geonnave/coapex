defmodule Coapex.Encoder do
  use Bitwise

  alias Coapex.{Message, Registry}

  @doc """
  Transforms a Message struct into a binary Coap Message.

  The Message struct is built by the user. It must then be transformed into a
   binary chunk, according to RFC7252, which specifies the Coap Message Format.

  The output of this function is meant to be transmitted down to peers via UDP.
  """
  def encode(%Message{version: v, type: t, code: c, token: tk, msg_id: id, options: opts, payload: p}) do
    {token, tk_len} = encode_token(tk)
    <<v::size(2), encode_type(t)::bitstring,
      tk_len::bitstring, encode_code(c)::bitstring,
      encode_msg_id(id)::bitstring, token::bitstring,
      encode_options(opts)::bitstring, 0xFF, encode_payload(p)::bitstring>>
  end

  @doc """
  Type: 2-bit unsigned integer.  Indicates if this message is of
    type Confirmable (0), Non-confirmable (1), Acknowledgement (2), or
    Reset (3).
  """
  def encode_type(type) do
    <<Registry.types[type]::size(2)>>
  end

  @doc """
  The Token is used to match a response with a request.  The token
    value is a sequence of 0 to 8 bytes.
  """
  def encode_token(nil), do: encode_token(<<>>)
  def encode_token(token) when is_binary(token) do
    {token, <<String.length(token)::unsigned-integer-size(4)>>}
  end

  @doc """
  Code: 8-bit unsigned integer, split into a 3-bit class (most
    significant bits) and a 5-bit detail (least significant bits),
    In case of a request, the Code field indicates the Request Method;
    in case of a response, a Response Code.
  """
  def encode_code(code) when is_atom(code) do
    encode_code(Registry.codes[code])
  end
  def encode_code(<<class, ".", detail::binary>>) do
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

  # TODO: review this
  def encode_payload(nil), do: <<>>
  def encode_payload(payload) when is_binary(payload), do: payload
  def encode_payload(payload) when is_number(payload), do: :binary.encode_unsigned(payload)

  @doc """
  Each option instance in a message specifies the Option Number of the
    defined CoAP option, the length of the Option Value, and the Option
    Value itself.
  """
  def encode_options(options) do
    options
    |> Stream.map(fn({o, v}) ->
      cond do
        is_nil(v) -> nil
        is_atom(o) and Registry.options[o] -> {Registry.options[o], v}
        is_atom(o) -> {o |> to_string |> String.to_integer, v}
        true -> nil
      end
    end)
    |> Stream.reject(&is_nil/1)
    |> Enum.sort(fn({o1, _v1}, {o2, _v2}) -> o1 <= o2 end)
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
  def build_options([{op, value} | rest], prev_op) do
    delta = op - prev_op

    value = encode_value(op, value)
    value_len = String.length(value)

    {del, ext_del} = encode_option_header(delta)
    {len, ext_len} = encode_option_header(value_len)

    <<del::bitstring, len::bitstring,
      ext_del::bitstring, ext_len::bitstring,
      value::bitstring>> <> build_options(rest, op)
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
  def encode_option_header(value) when value in 0..12, do: {<<value::unsigned-integer-size(4)>>, <<>>}
  def encode_option_header(value) when value > 12 and value <= 255 do
    {<<13::unsigned-integer-size(4)>>, <<(value-13)::unsigned-integer-size(8)>>}
  end
  def encode_option_header(value) when value > 255 and value < (1 <<< 16) do
    {<<14::unsigned-integer-size(4)>>, <<(value-269)::unsigned-integer-size(16)>>}
  end

  def encode_value(_, nil), do: <<>>
  def encode_value(op, value) when op in [12, 17] do
    Registry.content_formats[value] |> :binary.encode_unsigned
  end
  def encode_value(op, value) do
    case Registry.options_table[op][:format] do
      :uint -> :binary.encode_unsigned(value)
      _opaque_or_string -> value
    end
  end

end
