defmodule ProtoValidator.Utils do
  @moduledoc ""

  def pipe_validates(objects, validate_fun) do
    objects
    |> Stream.map(fn object -> validate_fun.(object) end)
    |> Stream.filter(&Kernel.match?({:error, _msg}, &1))
    |> Enum.at(0, :ok)
  end

  defguard is_internal_type(type)
           when type in [
                  :integer,
                  :double,
                  :float,
                  :int64,
                  :uint64,
                  :int32,
                  :fixed64,
                  :fixed32,
                  :bool,
                  :string,
                  :group,
                  :bytes,
                  :uint32,
                  :sfixed32,
                  :sfixed64,
                  :sint32,
                  :sint64,
                  :message
                ]
end
