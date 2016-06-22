defmodule Coapex.Message do
  @moduledoc """
  The Message struct is supposed to be filled by the user,
  with user-friendly types like strings and integers; also,
  the user will probably use Message.options and Message.types
  helper functions for fulfilling the struct.
  """
  defstruct [:type, :token, :code, :msg_id, :options, :payload]

  def init([method: method, uri: uri, opts: opts]) do
    %Coapex.Message{
      code: method_codes[method],
      type: types[opts[:type]],
      token: opts[:token],
      msg_id: :crypto.strong_rand_bytes(2),
      payload: opts[:payload],
    }
  end

  def options, do: [
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
  def response_codes, do: [
    created: to_code(2, 01),
    deleted: to_code(2, 02),
    valid: to_code(2, 03),
    changed: to_code(2, 04),
    content: to_code(2, 05),
    bad_request: to_code(4, 00),
    unauthorized: to_code(4, 01),
    bad_option: to_code(4, 02),
    forbidden: to_code(4, 03),
    not_found: to_code(4, 04),
    method_not_allowed: to_code(4, 05),
    not_acceptable: to_code(4, 06),
    precondition_failed: to_code(4, 12),
    request_entity_too_large: to_code(4, 13),
    unsupported_content_format: to_code(4, 15),
    internal_server_error: to_code(5, 00),
    not_implemented: to_code(5, 01),
    bad_gateway: to_code(5, 02),
    service_unavailable: to_code(5, 03),
    gateway_timeout: to_code(5, 04),
    proxying_not_supported: to_code(5, 05),
  ]
  def method_codes, do: [get: 0x01, post: 0x02, put: 0x03, delete: 0x04]
  def types, do: [con: 0, non: 1, ack: 2, rst: 3]
  def version, do: <<1::size(2)>>

  defp to_code(class, detail), do: <<class::3, detail::5>>
end
