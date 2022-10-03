defmodule ProtoValidator.Validator.Vex.Contains do
  use Vex.Validator

  @message_fields [
    value: "Bad value"
  ]
  def validate(value, options) when is_binary(options), do: validate(value, has: options)

  def validate(value, options) when is_list(options) do
    needle = Keyword.get(options, :has, "")

    if String.contains?(value, needle) do
      :ok
    else
      {:error, message(options, "must contain", value: value)}
    end
  end
end
