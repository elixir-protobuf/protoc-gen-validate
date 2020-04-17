defmodule ProtoValidator.Protoc.Generator do
  @moduledoc false

  alias Protobuf.Protoc.Metadata

  def generate(file, ctx) do
    name = new_file_name(file.fqn)

    Google.Protobuf.Compiler.CodeGeneratorResponse.File.new(
      name: name,
      content: generate_content(file, ctx)
    )
  end

  defp new_file_name(name) do
    String.replace_suffix(name, ".proto", ".pb.validate.ex")
  end

  defp generate_content(%Metadata.File{messages: messages} = file, ctx) do
    all_msgs = Metadata.File.all_messages(file)

    messages_code =
      all_msgs
      |> Enum.map(fn msg -> generate_message(msg, ctx) end)
      |> Enum.join("\n")
      |> Protobuf.Protoc.Generator.format_code()
  end

  # TODO: put get_str functions to a separate module
  defp generate_message({msg_metadata, _msg_desc}, ctx) do
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
    validation_fields =
      msg_metadata
      |> Metadata.Message.fields()
      |> Enum.map(fn
        {_field_md,
         %{name: name, options: %{__pb_extensions__: %{{Validate.PbExtension, :rules} => rules}}}} ->
          {name, rules}

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil/1)
      |> gen_validation()
  end

  defp gen_validation([]), do: nil

  defp gen_validation(validations) do
    # :id, required: true, gt: 0, lt: 90
    Enum.map(validations, fn {name, %Validate.FieldRules{message: message, type: type}} ->
      message_rule_str_list = get_rule_str_list(message)
      type_rule_str_list = get_rule_str_list(type)

      rules_str =
        message_rule_str_list
        |> Kernel.++(type_rule_str_list)
        |> Enum.join(", ")

      ":#{name}, #{rules_str}"
    end)
  end

  defp get_rule_str_list(nil), do: []

  defp get_rule_str_list({_type, type_rules}), do: get_rule_str_list(type_rules)

  defp get_rule_str_list(rules) do
    rules |> Map.from_struct() |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end
end
