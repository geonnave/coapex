# Coapex

CoAP ([rfc7252](https://tools.ietf.org/html/rfc7252)) stands for Constrained Application Protocol and is intended for use in embedded devices (e.g IoT stuff).

A quick (but not quite exact) comparison is "CoAP is a HTTP with binary header". CoAP supports REST as well, but it does support further things like "observation" of resources (like a Publish/Subscribe system).

# Done

* Encoder: allows the user to build a CoAP binary message from a `%Message` struct
```
iex> msg = Message.init(:request,
                       type: :con, code: :get, msg_id: 123,
                       options: [uri_host: "example.com", accept: "application/json"])
iex> Coapex.Encoder.encode(msg)
<<64, 1, 0, 123, 59, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109, 65, 87,
  255, 97, 98, 99>>
```

* Decoder: convert a CoAP binary message into a friendly `%Message` struct
```
iex> msg = Message.init(:request,
                       type: :con, code: :get, msg_id: 123,
                       options: [uri_host: "example.com", accept: "application/json"])
iex> bin_msg = Encoder.encode(msg)
iex> msg = Decoder.decode(bin_msg)
%Coapex.Message{code: :get, msg_id: 123,
 options: [uri_host: "example.com", uri_port: "W"], payload: "abc", token: nil,
 type: :con, version: <<1::size(2)>>}
```

# TODO:

* Server: understand & implement how to serve CoAP resources. Note: CoAP runs over UDP.
* Client: build a CoAP client

## extra thinking
what if we turn this into a Plug-like CoAP thing?

