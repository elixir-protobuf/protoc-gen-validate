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

  @doc """
  Translate rules
  from:
    [required: true, gt: 0, lt: 90]
  to:
    [
      {Vex.Validators.Number, [greater_than: 0, message: "The id should greater than 0"]},
      {Vex.Validators.Number, [less_than: 90, message: "The id should less than 90"]},
      {Vex.Validators.Presence, [message: "The id should exists"]} 
    ]
  """
  def translate_rules(field, rules) do
    rules
    |> Enum.map(&translate_rule/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn {vex_module, options} ->
      message = Keyword.get(options, :message)
      message = "The #{field} #{message}"
      {vex_module, Keyword.put(options, :message, message)}
    end)
  end

  # TODO: put the rules translation to a separate file
  def translate_rule({:gt, v}),
    do: {Vex.Validators.Number, [greater_than: v, message: "should greater than #{v}"]}

  def translate_rule({:lt, v}),
    do: {Vex.Validators.Number, [less_than: v, message: "should less than #{v}"]}

  def translate_rule({:required, true}), do: {Vex.Validators.Presence, [message: "should exists"]}
  def translate_rule(), do: nil

  def validate_field(data, field, rules) do
    rules
    |> Stream.map(fn {vex_module, options} ->
      apply(vex_module, :validate, [Map.get(data, field), options])
    end)
    |> Stream.filter(&Kernel.match?({:error, _msg}, &1))
    |> Enum.at(0, :ok)
  end
end
