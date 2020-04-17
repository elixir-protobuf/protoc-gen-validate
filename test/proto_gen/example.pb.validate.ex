defmodule ProtoValidator.Gen.Examplepb.User do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.User

  validate(:id, required: true, gt: 0, lt: 90)
  validate(:email, required: true)
end
