defmodule ProtoValidator.Validator do
  @validator Application.get_env(:proto_validator, :validator, :vex)

  def get_validator() do
    get_validator(@validator)
  end

  defp get_validator(:vex), do: ProtoValidator.Validator.Vex

  def validate_uniq(nil), do: :ok

  def validate_uniq(value) do
    if Enum.uniq(value) == value, do: :ok, else: {:error, "values should be uniq"}
  end
end
