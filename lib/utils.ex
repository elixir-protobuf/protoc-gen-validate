defmodule ProtoValidator.Utils do
  @moduledoc ""

  def pipe_validates(objects, validate_fun) do
    objects
    |> Stream.map(fn object -> validate_fun.(object) end)
    |> Stream.filter(&Kernel.match?({:error, _msg}, &1))
    |> Enum.at(0, :ok)
  end
end
