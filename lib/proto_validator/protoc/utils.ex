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
    rules |> Map.from_struct() |> get_rule_str()
  end

  def get_rule_str(rules) when is_map(rules) do
    rule_str =
      rules
      |> Enum.map(fn
        {_k, nil} -> nil
        {k, v} when is_map(v) -> "#{k}: [#{get_rule_str(v)}]"
        {k, v} -> "#{k}: #{get_rule_str(v)}"
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    "#{rule_str}"
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
  defp get_type_name(type, nil), do: ":#{Protobuf.TypeUtil.from_enum(type)}"

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
end
