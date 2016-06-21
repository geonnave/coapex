# Coapex

CoAP ([rfc7252](https://tools.ietf.org/html/rfc7252)) stands for Constrained Application Protocol and is intended for use in embedded devices (e.g IoT stuff).

A quick (but not quite exact) comparison is "CoAP is a HTTP with binary header". CoAP supports REST as well, but it does support further things like "observation" of resources (like a Publish/Subscribe system).

# What has been Done so far

* Encoder: allows the user to build a CoAP binary message from a `%Message` struct
```
iex> msg = %Message{type: :con, token: <<>>, code: "0.01", msg_id: 11,
               options: ["Uri-Path": "baz", "Uri-Host": "foo.bar"],
               payload: "abc"}
iex> Coapex.Encoder.encode(msg)
<<64, 1, 0, 11, 55, 102, 111, 111, 46, 98, 97, 114, 131, 98, 97, 122, 255, 97, 98, 99>>
```

# What is TODO:

* Decoder: convert a CoAP binary message into a friendly `%Message` struct
```
iex> bin_msg = <<64, 1, 0, 11, 55, 102, 111, 111, 46, 98, 97, 114, 131, 98, 97, 122, 255, 97, 98, 99>>
iex> Coapex.Decoder.decode(bin_msg)
%Message{type: :con, token: <<>>, code: "0.01", msg_id: 11,
               options: ["Uri-Path": "baz", "Uri-Host": "foo.bar"],
               payload: "abc"}
```
* Server: understand & implement how to serve CoAP resources. Note: CoAP runs over UDP.

