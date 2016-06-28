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

  def parse_options(rest) do
    parse_options(rest, [])
  end

  def parse_options(<<delta::4, length::4, rest::binary>>) do
  end
  def parse_options(<<0xFF, rest::binary>>, options), do: {options, rest}

end
