defmodule Examplepb.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          email: String.t()
        }
  defstruct [:id, :email]

  field :id, 1, type: :uint64
  field :email, 2, type: :string
end
