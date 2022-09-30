defmodule Examplepb.GENDER do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :MALE, 0
  field :FEMALE, 1
  field :OTHER, 2
end

defmodule Examplepb.Phone do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :phone_number, 1, type: :uint64, json_name: "phoneNumber", deprecated: false
end

defmodule Examplepb.User do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :id, 1, type: :uint64, deprecated: false
  field :email, 2, type: :string, deprecated: false
  field :gender, 3, type: Examplepb.GENDER, enum: true
  field :phones, 4, repeated: true, type: Examplepb.Phone, deprecated: false

  field :following_ids, 5,
    repeated: true,
    type: :uint64,
    json_name: "followingIds",
    deprecated: false
end

defmodule Examplepb.Foo do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :int32, 1, type: :int32, deprecated: false
end

defmodule Examplepb.Bar do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :uuid, 1, type: :string, deprecated: false
end
