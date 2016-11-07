use Mix.Config

config :logger, level: :debug
config :logger, :console,
  format: "$metadata $message\n",
  metadata: [:module]
