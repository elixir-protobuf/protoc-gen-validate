defmodule ProtoValidator.Validator.Vex.LenBytes do
  use Vex.Validator

  alias Vex.Blank

  @message_fields [
    value: "Bad value",
    size: "Number of tokens",
    min: "Minimum acceptable value",
    max: "Maximum acceptable value"
  ]
  def validate(value, options) when is_integer(options), do: validate(value, is: options)
  def validate(value, min..max), do: validate(value, in: min..max)

  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      tokens = if Blank.blank?(value), do: "", else: value
      size = byte_size(value)
      {lower, upper} = limits = bounds(options)

      {findings, default_message} =
        case limits do
          {nil, nil} ->
            raise "Missing length validation range"

          {same, same} ->
            {size == same, "must have a byte length of #{same}"}

          {nil, max} ->
            {size <= max, "must have a byte length of no more than #{max}"}

          {min, nil} ->
            {min <= size, "must have a byte length of at least #{min}"}

          {min, max} ->
            {min <= size and size <= max, "must have a byte length between #{min} and #{max}"}
        end

      result(
        findings,
        message(options, default_message,
          value: value,
          tokens: tokens,
          size: size,
          min: lower,
          max: upper
        )
      )
    end
  end

  defp bounds(options) do
    is = Keyword.get(options, :is)
    min = Keyword.get(options, :min)
    max = Keyword.get(options, :max)
    range = Keyword.get(options, :in)

    cond do
      is -> {is, is}
      min -> {min, max}
      max -> {min, max}
      range -> {range.first, range.last}
      true -> {nil, nil}
    end
  end

  defp result(true, _), do: :ok
  defp result(false, message), do: {:error, message}
end
