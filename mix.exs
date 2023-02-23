defmodule Wasmtube.MixProject do
  use Mix.Project

  def project do
    [
      app: :wasmtube,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:wasmex, "~> 0.8.2"},
      {:jason, "~> 1.4"},
      {:file_system, "~> 0.2.10"}
    ]
  end
end
