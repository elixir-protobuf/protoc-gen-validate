defmodule ProtoValidator.DSL do
  defmacro __before_compile__(_env) do
    validator = ProtoValidator.Validator.get_validator()

    quote bind_quoted: [validator: validator] do
      Enum.map(@validations, fn {field, rules} ->
        rules = apply(validator, :translate_rules, [rules])

        def validate_value(unquote(field) = field, value) do
          apply(
            unquote(validator),
            :validate_value,
            [field, value, unquote(Macro.escape(rules))]
          )
        end
      end)

      def validate_value(field, _value), do: :ok
    end
  end

  defmacro validate(field, rules) do
    quote do
      @validations {unquote(field), unquote(rules)}
    end
  end
end
