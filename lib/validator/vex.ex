defmodule ProtoValidator.Validator.Vex do
  @moduledoc ""

  def validate_rule(field, value, rules) when is_list(rules) do
    rules
    |> ProtoValidator.Utils.pipe_validates(fn rule -> validate_rule(value, rule) end)
    |> case do
      :ok -> :ok
      # TODO: Improve error message
      {:error, msg} -> {:error, "Invalid #{field}, #{msg}"}
    end
  end

  def validate_rule(nil, {:items, _rule}), do: :ok

  def validate_rule(nil, {:array, rule}) do
    validate_rule([], rule)
  end

  def validate_rule(values, {:items, rule}) when is_list(values) do
    ProtoValidator.Utils.pipe_validates(values, fn value -> validate_rule(value, rule) end)
  end

  def validate_rule(values, {:array, rule}) when is_list(values) do
    validate_rule(values, rule)
  end

  def validate_rule(_values, {:array, _rule}) do
    {:error, "should be a list"}
  end

  def validate_rule(value, {:function, {m, f}}) do
    apply(m, f, [value])
  end

  def validate_rule(value, {vex_module, options}) when is_list(options) do
    apply(vex_module, :validate, [value, options])
  end

  def validate_rule(value, rule) do
    {:error, "Failed to validate value #{inspect(value)} against on rule: #{inspect(rule)}"}
  end

  @doc """
  Translate rules
  - raw rules:
    [type: :uint64, required: true, repeated: [items: [uint64: [gt: 0, lt: 90]], min_items: 0, unique: true]]
  - flatten:
    [
      required: true,
      repeated: {:items, {:uint64, {:gt, 0}}},
      repeated: {:items, {:uint64, {:lt, 90}}},
      repeated: {:min_items, 0},
      repeated: {:unique, true}
    ]
  - result:
    [
      {Vex.Validators.Presence, [message: "should exists"]},
      {:items, {Vex.Validators.Number, [greater_than: 0, message: "should greater than 0"]}},
      {:items, {Vex.Validators.Number, [less_than: 0, message: "should less than 90"]}},
      {:array, {Vex.Validators.Length, [nim: 0, message: "length should greater then 0"]}},
      {:function, {ProtoValidator.Validator.Vex, :validate_uniq}}
    ]
  """
  def translate_rules(rules) do
    rules
    |> flatten_rules()
    |> Enum.map(&translate_rule/1)
    |> Enum.reject(&is_nil/1)
  end

  def flatten_rules(rules) when is_list(rules) do
    rules
    |> Enum.map(fn
      {k, rules} when is_list(rules) ->
        rules
        |> flatten_rules()
        |> Enum.map(fn rule -> {k, rule} end)

      rule ->
        rule
    end)
    |> List.flatten()
  end

  def flatten_rules(rules), do: rules

  defp translate_rule({_, {:gt, v}}) do
    {Vex.Validators.Number, [greater_than: v, message: "should greater than #{v}"]}
  end

  defp translate_rule({_, {:gte, v}}) do
    {Vex.Validators.Number,
     [greater_than_or_equal_to: v, message: "should greater than or equal to #{v}"]}
  end

  defp translate_rule({_, {:lt, v}}) do
    {Vex.Validators.Number, [less_than: v, message: "should less than #{v}"]}
  end

  defp translate_rule({_, {:lte, v}}) do
    {Vex.Validators.Number,
     [less_than_or_equal_to: v, message: "should less than or equal to #{v}"]}
  end

  defp translate_rule({_, {:min_len, v}}) do
    {Vex.Validators.Length, [min: v, message: "length must be at least #{v}"]}
  end

  defp translate_rule({_, {:max_len, v}}) do
    {Vex.Validators.Length, [max: v, message: "length must be at most #{v}"]}
  end

  defp translate_rule({_, {:const, v}}) do
    {Vex.Validators.Inclusion, [in: [v], message: "value should be #{v}"]}
  end

  defp translate_rule({:required, true}) do
    {:function, {ProtoValidator.Validator, :validate_required}}
  end

  defp translate_rule({:repeated, {:items, rule}}) do
    {:items, translate_rule(rule)}
  end

  defp translate_rule({:repeated, {:min_items, v}}) do
    {:array, {Vex.Validators.Length, [min: v, message: "length should greater then #{v}"]}}
  end

  defp translate_rule({:repeated, {:max_items, v}}) do
    {:array, {Vex.Validators.Length, [max: v, message: "length should less then #{v}"]}}
  end

  defp translate_rule({:repeated, {:unique, true}}) do
    {:function, {ProtoValidator.Validator, :validate_uniq}}
  end

  defp translate_rule({:string, {:well_known, {:uuid, true}}}) do
    {Vex.Validators.Uuid, [format: :default]}
  end

  defp translate_rule(_) do
    nil
  end
end
