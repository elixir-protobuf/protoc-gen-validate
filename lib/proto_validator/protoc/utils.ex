defmodule ProtoValidator.Protoc.Utils do
  @moduledoc """
  """

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
end
