defmodule ProtoValidator.DSL do
  defmacro __before_compile__(_env) do
    quote unquote: false do
      Enum.map(@validations, fn {field, rules} ->
        rules = ProtoValidator.translate_rules(field, rules)

        def validate_field(unquote(field) = field, data) do
          ProtoValidator.validate_field(data, field, unquote(rules))
        end
      end)

      def validate_field(field, _data), do: true

      def validate(data) do
        @validations
        |> Stream.map(fn {field, _options} ->
          validate_field(field, data)
        end)
        |> Stream.filter(&Kernel.match?({:error, msg}, &1))
        |> Enum.at(0, :ok)
      end
    end
  end

  defmacro validate(field, rules) do
    quote do
      @validations {unquote(field), unquote(rules)}
    end
  end
end
