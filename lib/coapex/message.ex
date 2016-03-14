defmodule Coapex.Message do
  @moduledoc """
  The Message struct is supposed to be filled by the user,
  with user-friendly types like strings and integers; also,
  the user will probably use Message.options and Message.types
  helper functions for fulfilling the struct.
  """
  defstruct [:type, :token, :code, :msg_id, :options, :payload]

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
  def types, do: [con: 0, non: 1, ack: 2, rst: 3]
  def version, do: <<1::size(2)>>
end
