defmodule ProtoValidator.Validator.Vex.NotContains do
  use Vex.Validator

  @message_fields [
    value: "Bad value"
  ]
  def validate(value, options) when is_binary(options), do: validate(value, has_not: options)

  def validate(value, options) when is_list(options) do
    needle = Keyword.get(options, :has_not, "")

    if !String.contains?(value, needle) do
      :ok
    else
      {:error, message(options, "must not contain", value: value)}
    end
  end
end
