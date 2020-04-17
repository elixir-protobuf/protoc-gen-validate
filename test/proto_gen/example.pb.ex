defmodule Examplepb.User.GENDER do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :MALE | :FEMALE | :OTHER

  field(:MALE, 0)
  field(:FEMALE, 1)
  field(:OTHER, 2)
end

defmodule Examplepb.User.Phone do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          phone_number: String.t()
        }
  defstruct [:phone_number]

  field(:phone_number, 1, type: :string)
end

defmodule Examplepb.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          email: String.t(),
          gender: Examplepb.User.GENDER.t(),
          phone: Examplepb.User.Phone.t() | nil
        }
  defstruct [:id, :email, :gender, :phone]

  field(:id, 1, type: :uint64)
  field(:email, 2, type: :string)
  field(:gender, 3, type: Examplepb.User.GENDER, enum: true)
  field(:phone, 4, type: Examplepb.User.Phone)
end
