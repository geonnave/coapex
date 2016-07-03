defmodule Coapex.Decoder do
  alias Coapex.Message
  alias Coapex.Values

  use Bitwise

  def decode(message = <<
      1::2,
      type::2,
      token_len::4,
      code_class::3,
      code_detail::5,
      msg_id::16,
      token::size(token_len),
      rest::binary
      >>) do
    {options, payload} = decode_options_and_payload(rest)
    code = decode_code(code_class, code_detail)
    token = if token_len == 0, do: nil, else: token
    %Message{
      version: <<1::2>>, type: Values.from(:types)[type],
      code: code,
      msg_id: msg_id, token: token,
      options: options, payload: payload
    }
  end

  def decode_code(code_class, code_detail) do
    code = Integer.to_string(code_class) <> "."
      <> (Integer.to_string(code_detail) |> String.rjust(2, ?0))

    Values.from(:codes)[code]
  end

  def decode_options_and_payload(rest) do
    options_and_payload = decode_options(rest, 0)
    options = options_and_payload |> Keyword.delete(:payload)
    payload = case options_and_payload[:payload] do
                "" -> nil
                payload -> payload
    end
    {options, payload}
  end

  def decode_options(<<255, payload::binary>>, _prev_opt_number) do
    [{:payload, payload}]
  end
  def decode_options(<<delta::4, length::4, rest::binary>>, prev_opt_number) do
    {real_delta, rest} = decode_option_header(delta, rest)
    {real_length, rest} = decode_option_header(length, rest)

    <<value::binary-size(real_length), rest::binary>> = rest

    opt_number = prev_opt_number + real_delta
    opt_name = Values.from(:options)[opt_number] || opt_number

    [{opt_name, value} | decode_options(rest, opt_number)]
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

end
