defmodule Coapex.Values do

  def options, do: [
    if_match:        1,
    uri_host:        3,
    etag:            4,
    if_none_match:   5,
    uri_port:        7,
    location_path:   8,
    uri_path:       11,
    content_format: 12,
    max_age:        14,
    uri_query:      15,
    accept:         17,
    location_query: 20,
    proxy_uri:      35,
    proxy_scheme:   39,
    size1:          60
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
