defmodule ProtoValidator.Gen.Examplepb.Phone do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.Phone

  validate(:phone_number, type: :uint64, required: true, uint64: [gt: 1000, lt: 2000])
end

defmodule ProtoValidator.Gen.Examplepb.User do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.User

  validate(:id, type: :uint64, required: true, uint64: [gt: 0, lt: 90])
  validate(:email, type: :string, required: true, string: [max_len: 30, min_len: 5])
  validate(:gender, type: Examplepb.GENDER)
  validate(:phones, type: {:repeated, Examplepb.Phone}, repeated: [min_items: 1])

  validate(:following_ids,
    type: {:repeated, :uint64},
    repeated: [items: [uint64: [gt: 0, lt: 90]], min_items: 0, unique: true]
  )
end

defmodule ProtoValidator.Gen.Examplepb.Foo do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.Foo

  validate(:int32, type: :int32, int32: [gte: 0, lte: 10])
end