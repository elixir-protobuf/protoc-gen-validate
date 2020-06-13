defprotocol ProtoValidator.Verifiable do
  @doc ""
  @fallback_to_any true
  def validate(data)
end

defimpl ProtoValidator.Verifiable, for: Any do
  @impl true
  def validate(_), do: :ok
end

defmodule ProtoValidator do
  @moduledoc """
  user = %Examplepb.User{id: 1, email: "example@example.com"}
  ProtoValidator.validate(user)
  ProtoValidator.Gen.Examplepb.User.validate(user)
  ProtoValidator.validate(Examplepb.User, %{id: 1, email: "example@example.com"})
  """

  import ProtoValidator.Utils, only: [is_internal_type: 1, pipe_validates: 2]

  defmacro __using__(opts) do
    entity_module = Keyword.get(opts, :entity)

    quote location: :keep, bind_quoted: [entity_module: entity_module] do
      import ProtoValidator.DSL, only: [validate: 2]

      Module.register_attribute(__MODULE__, :validations, accumulate: true)

      # The validator module like ProtoValidator.Gen.Examplepb.User
      validator_module = __MODULE__

      defimpl ProtoValidator.Verifiable, for: entity_module do
        @validator_module validator_module

        @impl true
        def validate(data) do
          apply(@validator_module, :validate, [data])
        end
      end

      @before_compile ProtoValidator.DSL
    end
  end

  def validate(data_list) when is_list(data_list) do
    pipe_validates(data_list, &validate(&1))
  end

  def validate(data), do: ProtoValidator.Verifiable.validate(data)

  def validate(module, data_list) when is_list(data_list) do
    pipe_validates(data_list, &validate(module, &1))
  end

  def validate(module, %_{} = data) do
    if Map.get(data, :__struct__) == module do
      validate(data)
    else
      {:error, "Can not match data #{inspect(data)} on type #{inspect(module)}"}
    end
  end

  def validate(module, data) when is_map(data) do
    module
    |> struct(data)
    |> ProtoValidator.Verifiable.validate()
  rescue
    err -> {:error, inspect(err)}
  end

  def validate(module, data) when is_internal_type(module) do
    ProtoValidator.Validator.validate_internal_type(module, data)
  end

  def validate(_, _), do: :ok
end
