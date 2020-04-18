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
      # raise inspect(pkgs, limit: :infinity)

      # msg = Google.Protobuf.FieldOptions.new()
      # rules = %Validate.FieldRules{}
      # msg = Google.Protobuf.FieldOptions.put_extension(msg, Validate.PbExtension, :rules, rules)
      # raise inspect(Google.Protobuf.FieldOptions.get_extension(msg, Validate.PbExtension, :rules))

      # debug end

      files =
        pkgs
        |> Enum.flat_map(fn pkg -> pkg.files end)
        |> Enum.map(fn file_metadata ->
          ProtoValidator.Protoc.Generator.generate(file_metadata)
        end)

      Google.Protobuf.Compiler.CodeGeneratorResponse.new(file: files)
    end)
  end
end
