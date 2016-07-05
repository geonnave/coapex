defmodule DecoderTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Decoder
  alias Coapex.Encoder
  alias Coapex.Values

  @host_option Values.options[:uri_host]
  @path_option Values.options[:uri_path]
  @port_option Values.options[:uri_port]
  @size1_option Values.options[:size1]
  @custom_option 600

  test "decode message" do
    msg = Message.init(:request,
                       type: :con, code: :get, msg_id: 123,
                       options: [uri_host: "example.com", accept: "application/json"])

    bin_msg = Encoder.encode(msg)

    assert msg == Decoder.decode(bin_msg)
  end

  test "decode option delta" do
    delta = 0

    delta = 3 = 3 - 0 = @host_option - delta
    bin_opt = <<delta::size(4), 3::4, "x.y", 255>>
    assert [{:uri_host, "x.y"}, _] = Decoder.decode_options(bin_opt, 0)

    delta = 8 = 11 - 3 = @path_option - delta
    bin_opt = <<delta::size(4), 3::4, "foo", 255>>
    assert [{:uri_path, "foo"}, _] = Decoder.decode_options(bin_opt, 3)

    delta = 52 = 60 - 8 = @size1_option - delta
    del = 13
    ext_del = delta - 13
    bin_opt = <<del::size(4), 1::4, ext_del::size(8), 4, 255>>
    assert [{:size1, <<4>>}, _] = Decoder.decode_options(bin_opt, 8)

    delta = 548 = 600 - 52 = @custom_option - delta
    del = 14
    ext_del = delta - 269
    bin_opt = <<del::size(4), 1::4, ext_del::size(16), 18, 255>>
    assert [{600, <<18>>}, _] = Decoder.decode_options(bin_opt, 52)
  end

  test "decode extended option length" do
    delta = 0
    value = "string greater than 12 but lower than 255 bytes"
    value_len = String.length(value)

    delta = 3 = 3 - 0 = @host_option - delta
    len = 13
    ext_len = value_len - 13
    bin_opt = <<delta::size(4), len::size(4), ext_len::size(8), value::binary, 255>>
    assert [{:uri_host, _value}, _] = Decoder.decode_options(bin_opt, 0)

    delta = 0
    value = "string greater than 255 bytes" <> Enum.reduce(1..300, <<>>, &(&2 <> <<&1>>))
    value_len = String.length(value)

    delta = 3 = 3 - 0 = @host_option - delta
    len = 14
    ext_len = value_len - 269
    bin_opt = <<delta::size(4), len::size(4), ext_len::size(16), value::binary, 255>>
    assert [{:uri_host, _value}, _] = Decoder.decode_options(bin_opt, 0)
  end

  test "decode a number of options" do
    bin_opt = Encoder.encode_options([uri_host: "x.y", uri_path: "foo"]) <> <<255>>
    assert [{:uri_host, "x.y"},
            {:uri_path, "foo"}, _] = Decoder.decode_options(bin_opt, 0)

    bin_opt = Encoder.encode_options([uri_host: "x.y", uri_path: "foo"]) <> <<255>> <> "Hi!"
    assert [{:uri_host, "x.y"},
            {:uri_path, "foo"}, {:payload, "Hi!"}] = Decoder.decode_options(bin_opt, 0)
  end

end
