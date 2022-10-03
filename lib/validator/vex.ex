defmodule ProtoValidator.Validator.Vex do
  @moduledoc ""

  alias ProtoValidator.Validator.Vex.{
    Contains,
    LenBytes,
    NotContains,
    Prefix,
    Suffix
  }

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
    flattened_rules = flatten_rules(rules)

    flattened_rules
    |> Enum.map(&translate_rule(&1, flattened_rules))
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

  defp translate_rule({_, {:gt, v}}, _context) do
    {Vex.Validators.Number, [greater_than: v, message: "should greater than #{v}"]}
  end

  defp translate_rule({_, {:gte, v}}, _context) do
    {Vex.Validators.Number,
     [greater_than_or_equal_to: v, message: "should greater than or equal to #{v}"]}
  end

  defp translate_rule({_, {:lt, v}}, _context) do
    {Vex.Validators.Number, [less_than: v, message: "should less than #{v}"]}
  end

  defp translate_rule({_, {:lte, v}}, _context) do
    {Vex.Validators.Number,
     [less_than_or_equal_to: v, message: "should less than or equal to #{v}"]}
  end

  defp translate_rule({_, {:min_len, v}}, _context) do
    {Vex.Validators.Length, [min: v, message: "length must be at least #{v}"]}
  end

  defp translate_rule({_, {:max_len, v}}, _context) do
    {Vex.Validators.Length, [max: v, message: "length must be at most #{v}"]}
  end

  defp translate_rule({_, {:const, v}}, _context) do
    {Vex.Validators.Inclusion, [in: [v], message: "value should be #{v}"]}
  end

  defp translate_rule({:required, true}, _context) do
    {:function, {ProtoValidator.Validator, :validate_required}}
  end

  defp translate_rule({:repeated, {:items, rule}}, context) do
    {:items, translate_rule(rule, context)}
  end

  defp translate_rule({:repeated, {:min_items, v}}, _context) do
    {:array, {Vex.Validators.Length, [min: v, message: "length should greater then #{v}"]}}
  end

  defp translate_rule({:repeated, {:max_items, v}}, _context) do
    {:array, {Vex.Validators.Length, [max: v, message: "length should less then #{v}"]}}
  end

  defp translate_rule({:repeated, {:unique, true}}, _context) do
    {:function, {ProtoValidator.Validator, :validate_uniq}}
  end

  defp translate_rule({:string, {:well_known, {:uuid, true}}}, _context) do
    {Vex.Validators.Uuid, [format: :default]}
  end

  defp translate_rule({:string, {:len, v}}, _context) do
    {Vex.Validators.Length, [is: v, message: "length should be #{v}"]}
  end

  defp translate_rule({:string, {:len_bytes, v}}, _context) do
    {LenBytes, [is: v, message: "length bytes should be #{v}"]}
  end

  defp translate_rule({:string, {:min_bytes, v}}, _context) do
    {LenBytes, [min: v, message: "byte length must be at least #{v}"]}
  end

  defp translate_rule({:string, {:max_bytes, v}}, _context) do
    {LenBytes, [max: v, message: "byte length must be at most #{v}"]}
  end

  defp translate_rule({:string, {:pattern, v}}, _context) do
    {Vex.Validators.Format, [with: ~r/#{v}/, message: "should match the pattern #{v}"]}
  end

  defp translate_rule({:string, {:prefix, v}}, _context) do
    {Prefix, [starts: v, message: "should start with #{v}"]}
  end

  defp translate_rule({:string, {:suffix, v}}, _context) do
    {Suffix, [ends: v, message: "should end with #{v}"]}
  end

  defp translate_rule({:string, {:contains, v}}, _context) do
    {Contains, [has: v, message: "should contain #{v}"]}
  end

  defp translate_rule({:string, {:not_contains, v}}, _context) do
    {NotContains, [has_not: v, message: "should not contain #{v}"]}
  end

  defp translate_rule(_, _) do
    nil
  end
end
