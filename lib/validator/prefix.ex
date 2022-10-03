defmodule ProtoValidator.Validator.Vex.Prefix do
  use Vex.Validator

  @message_fields [
    value: "Bad value"
  ]
  def validate(value, options) when is_binary(options), do: validate(value, starts: options)

  def validate(value, options) when is_list(options) do
    prefix = Keyword.get(options, :starts, "")

    if String.starts_with?(value, prefix) do
      :ok
    else
      {:error, message(options, "must start with", value: value)}
    end
  end
end
