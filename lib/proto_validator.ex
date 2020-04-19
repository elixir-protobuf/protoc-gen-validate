defprotocol ProtoValidator.Verifiable do
  @doc ""
  @fallback_to_any true
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
    # entity_module = Keyword.get(opts, :entity)

    quote location: :keep do
      import ProtoValidator.DSL, only: [validate: 2]

      @options unquote(opts)
      Module.register_attribute(__MODULE__, :validations, accumulate: true)

      validator_module = __MODULE__

      entity_module = Keyword.get(@options, :entity)

      defimpl ProtoValidator.Verifiable, for: entity_module do
        @validator_module validator_module
        def validate(data) do
          apply(@validator_module, :validate, [data])
        end
      end

      def validate(%{__struct__: protobuf_module} = data) do
        props = protobuf_module.__message_props__()

        props
        |> Map.get(:field_props)
        |> Stream.filter(fn {_, %{oneof: oneof}} -> is_nil(oneof) end)
        |> ProtoValidator.Utils.pipe_validates(fn {_, %{name_atom: field} = field_prop} ->
          value = Map.get(data, field)

          case validate_value(field, value) do
            :ok -> validate_field(field_prop, value)
            {:error, msg} -> {:error, msg}
          end
        end)
      end

      def validate(data) when is_map(data) do
        @options |> Keyword.get(:entity) |> struct(data) |> validate()
      end

      def validate(_), do: :ok

      def validate_field(_, nil), do: :ok

      def validate_field(%{type: type, repeated?: true}, values) do
        ProtoValidator.Utils.pipe_validates(values, fn value ->
          ProtoValidator.validate(type, value)
        end)
      end

      def validate_field(%{type: type} = field_prop, value) do
        ProtoValidator.validate(type, value)
      end

      @before_compile ProtoValidator.DSL
    end
  end

  def validate(%_{} = data) do
    ProtoValidator.Verifiable.validate(data)
  end

  def validate(_), do: :ok

  def validate(_module, %_{} = data) do
    validate(data)
  end

  def validate(module, data) when is_map(data) do
    module
    |> struct(data)
    |> ProtoValidator.Verifiable.validate()
  rescue
    err -> {:error, inspect(err)}
  end

  def validate(_, _), do: :ok
end
