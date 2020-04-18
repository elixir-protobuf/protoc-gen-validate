defprotocol ProtoValidator.Verifiable do
  @doc ""
  def validate(data)
end

defimpl ProtoValidator.Verifiable, for: Any do
  def validate(_), do: :ok
end

defmodule ProtoValidator do
  @moduledoc """
  user = %Examplepb.User{id: 1, email: "example@example.com"}
  ProtoValidator.validate(user)
  ProtoValidator.Gen.Examplepb.User.validate(user)
  ProtoValidator.validate(Examplepb.User, %{id: 1, email: "example@example.com"})
  """

  defmacro __using__(opts) do
    entity_module = Keyword.get(opts, :entity)

    quote location: :keep do
      import unquote(__MODULE__), except: [validate: 2]
      import ProtoValidator.DSL, only: [validate: 2]

      @options unquote(opts)
      Module.register_attribute(__MODULE__, :validations, accumulate: true)

      validator_module = __MODULE__

      defimpl ProtoValidator.Verifiable, for: unquote(entity_module) do
        @validator_module validator_module
        def validate(data) do
          apply(@validator_module, :validate, [data])
        end
      end

      @before_compile ProtoValidator.DSL
    end
  end

  def validate(%_{} = data) do
    ProtoValidator.Verifiable.validate(data)
  end

  def validate(module, data) do
    module
    |> struct(data)
    |> ProtoValidator.Verifiable.validate()
  end
end
