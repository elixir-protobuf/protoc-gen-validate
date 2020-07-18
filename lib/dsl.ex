defmodule ProtoValidator.DSL do
  defmacro __before_compile__(_env) do
    validator = ProtoValidator.Validator.get_validator()

    quote bind_quoted: [validator: validator] do
      @doc """
      Validate a field value
      """
      Enum.map(@validations, fn {field, [{:type, type} | rules]} ->
        rules = validator.translate_rules(rules)

        def validate_value(unquote(field) = field, value) do
          case ProtoValidator.Validator.validate_type(unquote(Macro.escape(type)), value) do
            :ok ->
              unquote(validator).validate_rule(field, value, unquote(Macro.escape(rules)))

            error ->
              error
          end
        end
      end)

      def validate_value(field, _value), do: :ok

      def validate(data) do
        ProtoValidator.Utils.pipe_validates(@validations, fn {field, _rules} ->
          value = Map.get(data, field)
          validate_value(field, value)
        end)
      end
    end
  end

  defmacro validate(field, rules) do
    quote do
      @validations {unquote(field), unquote(rules)}
    end
  end
end
