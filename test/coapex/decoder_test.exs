defmodule DecoderTest do
  use ExUnit.Case

  alias Coapex.Message
  alias Coapex.Decoder

  test "decode message" do
    bin_msg =
      Message.init(:request,
        type: :con, code: :get, msg_id: 123,
        options: [uri_host: "example.com", accept: "application/json"])
      |> Message.encode(:request)

    decoded_msg = Decoder.decode(bin_msg) |> IO.inspect
  end

end
