defmodule ProtoValidator.Validator.Vex.Suffix do
  use Vex.Validator

  @message_fields [
    value: "Bad value"
  ]
  def validate(value, options) when is_binary(options), do: validate(value, ends: options)

  def validate(value, options) when is_list(options) do
    suffix = Keyword.get(options, :ends, "")

    if String.ends_with?(value, suffix) do
      :ok
    else
      {:error, message(options, "must ends with", value: value)}
    end
  end
end
