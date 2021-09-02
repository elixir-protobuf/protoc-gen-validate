defmodule ProtoValidator.Validator do
  @validator Application.get_env(:proto_validator, :validator, :vex)

  import ProtoValidator.Utils, only: [pipe_validates: 2]

  def get_validator() do
    get_validator(@validator)
  end

  defp get_validator(:vex), do: ProtoValidator.Validator.Vex

  def validate_uniq(nil), do: :ok

  def validate_uniq(value) do
    if Enum.uniq(value) == value, do: :ok, else: {:error, "values should be uniq"}
  end

  def validate_required(nil), do: {:error, "value is required"}
  def validate_required(_value), do: :ok

  @doc """
  Validate the type of a field
  """
  @spec validate_type(atom() | {:repeated, atom()}, any()) :: :ok | {:error, String.t()}
  def validate_type(_, nil), do: :ok

  def validate_type({:repeated, type}, values) when is_list(values) do
    pipe_validates(values, &validate_type(type, &1))
  end

  def validate_type({:repeated, type}, value) do
    {:error, "#{inspect(value)} is not a list of #{inspect(type)}"}
  end

  def validate_type(type, value) do
    ProtoValidator.validate(type, value)
  end

  def validate_internal_type(_, nil), do: :ok

  def validate_internal_type(:uint64, value) when is_integer(value), do: :ok

  def validate_internal_type(:uint64, value), do: {:error, "#{inspect(value)} is not integer"}

  def validate_internal_type(_, _), do: :ok
end
