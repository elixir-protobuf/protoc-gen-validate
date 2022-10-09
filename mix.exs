defmodule ProtoValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :proto_validator,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:eex, :logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/proto_gen"]
  defp elixirc_paths(_), do: ["lib"]

  defp escript do
    [main_module: ProtoValidator.Protoc.CLI, name: "protoc-gen-validate"]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.11.0"},
      {:vex, "~> 0.9.0"},
      {:protoc_gen_validate,
       github: "bufbuild/protoc-gen-validate", branch: "main", app: false, compile: false}
    ]
  end

  defp package() do
    %{
      files: ~w(mix.exs README.md lib src LICENSE priv/templates .formatter.exs)
    }
  end
end
