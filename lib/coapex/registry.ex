defmodule Coapex.Registry do

  def version, do: <<1::size(2)>>

  # TODO: fix this infamous GAMBIARRA
  #       maybe use a macro to generate `to_` and `from_` functions
  def from(fun_name, value) when is_number(value) do
    from(fun_name, value |> Integer.to_string)
  end
  def from(fun_name, value) do
    inverted =
      apply(__MODULE__, fun_name, [])
      |> Enum.map(fn({n, o}) ->
        if is_number(o) do
          {o |> Integer.to_string |> String.to_atom, n}
        else
          {o |> String.to_atom, n}
        end
      end)

    value = value |> String.to_atom
    inverted[value]
  end

  def types, do: [con: 0, non: 1, ack: 2, rst: 3]

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

  def codes, do: [
    # request codes
    get: "0.01",
    post: "0.02",
    put: "0.03",
    delete: "0.04",
    # response codes
    created: "2.01",
    deleted: "2.02",
    valid: "2.03",
    changed: "2.04",
    content: "2.05",
    bad_request: "4.00",
    unauthorized: "4.01",
    bad_option: "4.02",
    forbidden: "4.03",
    not_found: "4.04",
    method_not_allowed: "4.05",
    not_acceptable: "4.06",
    precondition_failed: "4.12",
    request_entity_too_large: "4.13",
    unsupported_content_format: "4.15",
    internal_server_error: "5.00",
    not_implemented: "5.01",
    bad_gateway: "5.02",
    service_unavailable: "5.03",
    gateway_timeout: "5.04",
    proxying_not_supported: "5.05",
  ]

end
