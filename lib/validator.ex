defmodule ProtoValidator.Validator do
  @validator Application.get_env(:proto_validator, :validator, :vex)

  def get_validator() do
    get_validator(@validator)
  end

  defp get_validator(:vex), do: ProtoValidator.Validator.Vex
end
