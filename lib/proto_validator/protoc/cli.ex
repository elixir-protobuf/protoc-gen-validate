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

      ctx =
        %Protobuf.Protoc.Context{}
        |> Protobuf.Protoc.find_types(request.proto_file)

      # debug
      # raise inspect(pkgs, limit: :infinity)

      files =
        pkgs
        |> Enum.flat_map(fn pkg -> pkg.files end)
        |> Enum.map(fn file_metadata ->
          ProtoValidator.Protoc.Generator.generate(ctx, file_metadata)
        end)
        |> Enum.reject(&is_nil/1)

      Google.Protobuf.Compiler.CodeGeneratorResponse.new(file: files)
    end)
  end
end
