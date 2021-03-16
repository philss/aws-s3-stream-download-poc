defmodule DownloadManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :download_manager,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DownloadManager.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:aws, ">= 0.0.0"},
      {:finch, ">= 0.0.0"}
    ]
  end
end
