defmodule Coapex.Decoder do
  alias Coapex.Message
  alias Coapex.Values

  use Bitwise

  def decode(message = <<
      1::2,
      type::2,
      token_len::4,
      code::8,
      msg_id::16,
      token::size(token_len),
      rest::binary
      >>) do
    %Message{
      version: <<1::2>>, type: type, code: code,
      msg_id: msg_id, token: token
    }
  end

  def decode_option(<<delta::4, length::4, rest::binary>>, prev_delta) do
    {real_delta, rest} = decode_option_header(delta, rest)
    {real_length, rest} = decode_option_header(length, rest)
    <<value::binary-size(real_length), rest::binary>> = rest
    {prev_delta + real_delta, real_length, value, rest}
  end

  def decode_option_header(value, rest) when value in 0..12 do
    {value, rest}
  end
  def decode_option_header(13, <<ext_val::8, rest::binary>>) do
    {ext_val + 13, rest}
  end
  def decode_option_header(14, <<ext_val::16, rest::binary>>) do
    {ext_val + 269, rest}
  end

  def parse_options(rest) do
    parse_options(rest, [])
  end

  def parse_options(<<delta::4, length::4, rest::binary>>) do
  end
  def parse_options(<<0xFF, rest::binary>>, options), do: {options, rest}

end
