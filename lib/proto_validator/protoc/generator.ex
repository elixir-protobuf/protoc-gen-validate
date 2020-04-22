defmodule ProtoValidator.Protoc.Generator do
  @moduledoc false

  alias Protobuf.Protoc.Metadata
  alias ProtoValidator.Protoc.Utils
  alias Google.Protobuf.Compiler.CodeGeneratorResponse

  def generate(file) do
    name = new_file_name(file.fqn)

    case generate_content(file) do
      nil ->
        nil

      content ->
        CodeGeneratorResponse.File.new(name: name, content: content)
    end
  end

  defp new_file_name(name) do
    String.replace_suffix(name, ".proto", ".pb.validate.ex")
  end

  defp generate_content(%Metadata.File{} = file) do
    file
    |> Metadata.File.all_messages()
    |> Enum.map(fn msg -> generate_message(msg) end)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        nil

      validations ->
        validations
        |> Enum.join("\n")
        |> Protobuf.Protoc.Generator.format_code()
    end
  end

  # TODO: put get_str functions to a separate module
  defp generate_message({msg_metadata, _msg_desc}) do
    case get_validations(msg_metadata) do
      nil ->
        nil

      validations ->
        {entity, validate_name} = get_message_name(msg_metadata)
        option_str = get_options_str(%{entity: entity})
        ProtoValidator.Protoc.Template.message(validate_name, option_str, validations)
    end
  end

  defp get_message_name(%Metadata.Message{fqn: fqn}) do
    names =
      fqn
      |> String.split(".")
      |> Enum.map(&String.capitalize/1)

    {Enum.join(names, "."), Enum.join(["ProtoValidator.Gen" | names], ".")}
  end

  defp get_options_str(options) do
    str = Protobuf.Protoc.Generator.Util.options_to_str(options)
    if String.length(str) > 0, do: ", " <> str, else: ""
  end

  defp get_validations(msg_metadata) do
    msg_metadata
    |> Metadata.Message.fields()
    |> Enum.map(fn
      {_field_md, %{name: name, options: %{} = options}} ->
        case Google.Protobuf.FieldOptions.get_extension(options, Validate.PbExtension, :rules) do
          nil ->
            nil

          rules ->
            {name, rules}
        end

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
    |> gen_validation()
  end

  defp gen_validation([]), do: nil

  defp gen_validation(validations) do
    Enum.map(validations, fn {name, rules} ->
      ":#{name}, #{Utils.get_rule_str(rules)}"
    end)
  end
end
