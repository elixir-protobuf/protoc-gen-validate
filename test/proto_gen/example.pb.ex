defmodule Examplepb.GENDER do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :MALE | :FEMALE | :OTHER

  field :MALE, 0

  field :FEMALE, 1

  field :OTHER, 2
end

defmodule Examplepb.Phone do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          phone_number: non_neg_integer
        }

  defstruct [:phone_number]

  field :phone_number, 1, type: :uint64, json_name: "phoneNumber"
end

defmodule Examplepb.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          email: String.t(),
          gender: Examplepb.GENDER.t(),
          phones: [Examplepb.Phone.t()],
          following_ids: [non_neg_integer]
        }

  defstruct [:id, :email, :gender, :phones, :following_ids]

  field :id, 1, type: :uint64
  field :email, 2, type: :string
  field :gender, 3, type: Examplepb.GENDER, enum: true
  field :phones, 4, repeated: true, type: Examplepb.Phone
  field :following_ids, 5, repeated: true, type: :uint64, json_name: "followingIds"
end
