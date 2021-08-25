defmodule ProtoValidator.Protoc.Generator do
  @moduledoc false

  alias ProtoValidator.Protoc.Utils
  alias Google.Protobuf.Compiler.CodeGeneratorResponse

  def generate(ctx, desc) do
    name = new_file_name(desc.name)

    case generate_content(ctx, desc) do
      nil ->
        nil

      content ->
        CodeGeneratorResponse.File.new(name: name, content: content)
    end
  end

  defp new_file_name(name) do
    String.replace_suffix(name, ".proto", ".pb.validate.ex")
  end

  defp generate_content(ctx, desc) do
    ctx = %{ctx | package: desc.package || ""}
    ctx = Protobuf.Protoc.Context.cal_file_options(ctx, desc.options)

    type_mappings =
      for {_file_name, mappings} <- ctx.global_type_mapping,
          {dot_prefixed_fqn, type_name_map} <- mappings,
          into: %{} do
        <<?., fqn::binary>> = dot_prefixed_fqn
        {fqn, type_name_map.type_name}
      end

    desc.message_type
    |> Enum.map(fn desc -> generate_message(ctx, type_mappings, desc) end)
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

  defp generate_message(ctx, type_mappings, desc) do
    case get_validations(desc) do
      nil ->
        nil

      validations ->
        {entity, validate_name} = get_message_name(ctx, type_mappings, desc)
        option_str = get_options_str(%{entity: entity})
        ProtoValidator.Protoc.Template.message(validate_name, option_str, validations)
    end
  end

  defp get_message_name(ctx, type_mappings, desc) do
    # FIXME resolve nested message fqn
    fqn = ctx.package <> "." <> desc.name
    module_name = Map.fetch!(type_mappings, fqn)
    {module_name, "ProtoValidator.Gen.#{module_name}"}
  end

  defp get_options_str(options) do
    str = Protobuf.Protoc.Generator.Util.options_to_str(options)
    if String.length(str) > 0, do: ", " <> str, else: ""
  end

  defp get_validations(desc) do
    desc.field
    |> Enum.map(fn
      field_metadata ->
        %{name: name, type: type, type_name: type_name, label: label} = field_metadata
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
