defmodule ProtoValidator.Validator.Vex do
  @moduledoc ""

  def validate_field(data, field, rules) do
    rules
    |> Stream.map(fn {vex_module, options} ->
      apply(vex_module, :validate, [Map.get(data, field), options])
    end)
    |> Stream.filter(&Kernel.match?({:error, _msg}, &1))
    |> Enum.at(0, :ok)
  end

  @doc """
  Translate rules
  from:
    [required: true, uint64: [gt: 0, lt: 90]]
  to:
    [
      {Vex.Validators.Number, [greater_than: 0, message: "The id should greater than 0"]},
      {Vex.Validators.Number, [less_than: 90, message: "The id should less than 90"]},
      {Vex.Validators.Presence, [message: "The id should exists"]} 
    ]
  """
  def translate_rules(field, rules) do
    rules
    |> flatten_rules()
    |> Enum.map(&translate_rule/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn {vex_module, options} ->
      message = Keyword.get(options, :message)
      message = "The #{field} #{message}"
      {vex_module, Keyword.put(options, :message, message)}
    end)
  end

  defp flatten_rules(rules) do
    rules
    |> Enum.map(fn
      {_type, type_rules} when is_list(type_rules) -> type_rules
      rules -> rules
    end)
    |> List.flatten()
  end

  defp translate_rule({:gt, v}),
    do: {Vex.Validators.Number, [greater_than: v, message: "should greater than #{v}"]}

  defp translate_rule({:lt, v}),
    do: {Vex.Validators.Number, [less_than: v, message: "should less than #{v}"]}

  defp translate_rule({:required, true}),
    do: {Vex.Validators.Presence, [message: "should exists"]}

  defp translate_rule(_), do: nil
end
