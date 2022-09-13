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
    :io.setopts(:standard_io, encoding: :latin1)
    Protobuf.load_extensions()

    bin = IO.binread(:all)
    request = Protobuf.Decoder.decode(bin, Google.Protobuf.Compiler.CodeGeneratorRequest)

    ctx =
      Protobuf.Protoc.CLI.find_types(
        %Protobuf.Protoc.Context{},
        request.proto_file,
        request.file_to_generate
      )

    files =
      request.proto_file
      |> Enum.filter(fn desc -> Enum.member?(request.file_to_generate, desc.name) end)
      |> Enum.map(fn desc -> ProtoValidator.Protoc.Generator.generate(ctx, desc) end)
      |> Enum.reject(&is_nil/1)

    response = Google.Protobuf.Compiler.CodeGeneratorResponse.new(file: files)
    IO.binwrite(Protobuf.Encoder.encode(response))
  end
end
