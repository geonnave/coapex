defmodule Coapex.Mixfile do
  use Mix.Project

  def project do
    [app: :coapex,
     version: "0.0.1",
     elixir: "~> 1.3.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Coapex, []}]
  end

  defp deps do
    [{:credo, "~> 0.3", only: [:dev, :test]}]
  end
end
