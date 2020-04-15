defmodule ProtoValidator.Protoc.CLI do
  @moduledoc """
  """

  @doc false
  def main(["--version"]) do
    {:ok, version} = :application.get_key(:proto_validator, :vsn)
    IO.puts(to_string(version))
  end

  def main([opt]) when opt in ["--help", "-h"] do
    IO.puts(@moduledoc)
  end

  def main(_) do
    Protobuf.Protoc.run(fn request ->
      pkgs = Protobuf.Protoc.Parser.parse(request)

      # debug
      raise inspect(pkgs, limit: :infinity)

      # raise :ets.lookup(Protobuf.Protoc.Parser, {:desc, "example.proto"})
      # msg = Google.Protobuf.FieldOptions.new()
      # rules = %Validate.FieldRules{}
      # msg = Google.Protobuf.FieldOptions.put_extension(msg, Validate.PbExtension, :rules, rules)
      # raise inspect(Google.Protobuf.FieldOptions.get_extension(msg, Validate.PbExtension, :rules))

      # debug end

      Google.Protobuf.Compiler.CodeGeneratorResponse.new(file: [])
    end)
  end
end
