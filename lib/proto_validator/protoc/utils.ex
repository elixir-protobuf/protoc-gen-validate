defmodule ProtoValidator.Protoc.Utils do
  @moduledoc false

  @doc """
  convert rules map to string:
  From:
    %Validate.FieldRules{
      message: %Validate.MessageRules{required: true},
      type: {
        :repeated,
        %Validate.RepeatedRules{
          items: %Validate.FieldRules{
            message: nil,
            type: {:uint64, %Validate.UInt64Rules{gt: 0, lt: 90}}
          },
          max_items: nil,
          min_items: 0,
          unique: true
        }
      }
    }

  To:
    "required: true, repeated: [items: [uint64: [gt: 0, lt: 90]], min_items: 0, unique: true]"
  """
  def get_rule_str(type, rules) do
    ["type: #{type}", get_rule_str(rules)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(",")
  end

  def get_rule_str(%{message: message, type: type}) do
    [get_rule_str(message), get_rule_str(type)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  def get_rule_str(nil), do: nil

  def get_rule_str(%_{} = rules) when is_map(rules) do
    rules |> Map.from_struct() |> Map.drop([:__unknown_fields__]) |> get_rule_str()
  end

  def get_rule_str(rules) when is_map(rules) do
    rule_str =
      rules
      |> Enum.map(fn
        {_k, nil} ->
          nil

        {k, v} when is_map(v) ->
          "#{k}: [#{get_rule_str(v)}]"

        {k, v} when is_tuple(v) ->
          "#{k}: [#{get_rule_str(v)}]"

        {k, v} ->
          "#{k}: #{get_rule_str(v)}"
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    "#{rule_str}"
  end

  def get_rule_str({type, type_rules}) when is_boolean(type_rules) do
    "#{type}: #{get_rule_str(type_rules)}"
  end

  def get_rule_str({type, type_rules}) do
    "#{type}: [#{get_rule_str(type_rules)}]"
  end

  def get_rule_str(v), do: to_string(v)

  @doc """
  Get type name string
  iex> get_type_name(:TYPE_MESSAGE, ".examplepb.User.Phone", :LABEL_REPEATED)
  "{:repeated, Examplepb.User.Phone}"

  iex> get_type_name(:TYPE_Enum, ".examplepb.User.Gender", :LABEL_OPTIONAL)
  "Examplepb.User.Gender"

  iex> get_type_name(:TYPE_STRING, nil, :LABEL_OPTIONAL)
  ":string"
  """
  def get_type_name(type, type_name, :LABEL_REPEATED) do
    "{:repeated, #{get_type_name(type, type_name)}}"
  end

  def get_type_name(type, type_name, _), do: get_type_name(type, type_name)
  defp get_type_name(type, nil), do: ":#{from_enum(type)}"

  defp get_type_name(_type, type_name) do
    get_module_name(type_name)
  end

  @doc """
  iex> get_module_name("examplepb.User")
  "Examplepb.User"
  iex> get_module_name(".examplepb.Phone")
  "Examplepb.Phone"
  iex> get_module_name(".examplepb.GENDER")
  "Examplepb.Gender"
  """
  def get_module_name(module_str) do
    module_str
    |> String.split(".")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(".")
  end

  def from_enum(:TYPE_DOUBLE), do: :double
  def from_enum(:TYPE_FLOAT), do: :float
  def from_enum(:TYPE_INT64), do: :int64
  def from_enum(:TYPE_UINT64), do: :uint64
  def from_enum(:TYPE_INT32), do: :int32
  def from_enum(:TYPE_FIXED64), do: :fixed64
  def from_enum(:TYPE_FIXED32), do: :fixed32
  def from_enum(:TYPE_BOOL), do: :bool
  def from_enum(:TYPE_STRING), do: :string
  def from_enum(:TYPE_GROUP), do: :group
  def from_enum(:TYPE_MESSAGE), do: :message
  def from_enum(:TYPE_BYTES), do: :bytes
  def from_enum(:TYPE_UINT32), do: :uint32
  def from_enum(:TYPE_ENUM), do: :enum
  def from_enum(:TYPE_SFIXED32), do: :sfixed32
  def from_enum(:TYPE_SFIXED64), do: :sfixed64
  def from_enum(:TYPE_SINT32), do: :sint32
  def from_enum(:TYPE_SINT64), do: :sint64
end
