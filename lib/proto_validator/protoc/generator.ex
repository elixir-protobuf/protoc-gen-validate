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
    module_name = Utils.get_module_name(fqn)

    {module_name, "ProtoValidator.Gen.#{module_name}"}
  end

  defp get_options_str(options) do
    str = Protobuf.Protoc.Generator.Util.options_to_str(options)
    if String.length(str) > 0, do: ", " <> str, else: ""
  end

  defp get_validations(msg_metadata) do
    msg_metadata
    |> Metadata.Message.fields()
    |> Enum.map(fn
      {_field_md, %{name: name, type: type, type_name: type_name, label: label} = field_metadata} ->
        type = Utils.get_type_name(type, type_name, label)

        rules =
          field_metadata
          |> Map.get(:options)
          # %{options: nil}
          |> Kernel.||(%Google.Protobuf.FieldOptions{})
          |> Google.Protobuf.FieldOptions.get_extension(Validate.PbExtension, :rules)

        {name, type, rules}
    end)
    |> gen_validation()
  end

  defp gen_validation([]), do: nil

  defp gen_validation(validations) do
    Enum.map(validations, fn {name, type, rules} ->
      ":#{name}, #{Utils.get_rule_str(type, rules)}"
    end)
  end
end
