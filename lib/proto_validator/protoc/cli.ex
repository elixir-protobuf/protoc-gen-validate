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

      file_descs =
        pkgs
        |> Protobuf.Protoc.Metadata.Package.files()
        |> Enum.map(fn {_file_md, file_desc} -> file_desc end)

      ctx =
        %Protobuf.Protoc.Context{}
        |> parse_params(request.parameter)
        |> Protobuf.Protoc.find_types(file_descs)

      files =
        pkgs
        |> Enum.flat_map(fn pkg -> pkg.files end)
        |> Enum.map(fn file_metadata ->
          ProtoValidator.Protoc.Generator.generate(file_metadata, ctx)
        end)

      Google.Protobuf.Compiler.CodeGeneratorResponse.new(file: files)
    end)
  end

  @doc false
  def parse_params(ctx, params_str) when is_binary(params_str) do
    params = String.split(params_str, ",")
    parse_params(ctx, params)
  end

  def parse_params(ctx, ["plugins=" <> plugins | t]) do
    plugins = String.split(plugins, "+")
    ctx = %{ctx | plugins: plugins}
    parse_params(ctx, t)
  end

  def parse_params(ctx, ["gen_descriptors=true" | t]) do
    ctx = %{ctx | gen_descriptors?: true}
    parse_params(ctx, t)
  end

  def parse_params(ctx, _), do: ctx
end
