# ProtoValidator

Elixir implementation of https://github.com/envoyproxy/protoc-gen-validate

## Installation

```elixir
def deps do
  [
    {:proto_validator, "~> 0.1.0"}
  ]
end
```

## Usage
Developers import the ProtoValidator and annotate the messages and fields in their proto files with constraint rules:

``` Elixir
package emamplepb

message User {
  uint64 id    = 1 [(validate.rules) = {
    uint64: {gt: 0, lt: 90},
    message: {required: true}
  }];

  string email = 2 [(validate.rules).message.required = true];

  GENDER gender = 3;

  message Phone {
    string phone_number = 1 [(validate.rules) = {
      uint64: {gt: 1000, lt: 2000}, 
      message: {required: true}
    }];
  }

  repeated Phone phones = 4 [(validate.rules).repeated.min_items = 1];

  repeated uint64 following_ids = 5 [(validate.rules).repeated = {
    min_items: 0,
    unique: true,
    items: {uint64: {gt: 0, lt: 90}}
  }];
}
```
Then ProtoValidator will generate the validator modules for messages that have constraint rules automatically like:
``` Elixir
defmodule ProtoValidator.Gen.Examplepb.User do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.User

  validate(:id, required: true, uint64: [gt: 0, lt: 90])
  validate(:email, required: true)
  validate(:phones, repeated: [min_items: 1])

  validate(:following_ids,
    repeated: [items: [uint64: [gt: 0, lt: 90]], min_items: 0, unique: true]
  )
end

defmodule ProtoValidator.Gen.Examplepb.User.Phone do
  @moduledoc false
  use ProtoValidator, entity: Examplepb.User.Phone

  validate(:phone_number, required: true, uint64: [gt: 1000, lt: 2000])
end
```
Then both `&ProtoValidator.validate/1` and `&ProtoValidator.Gen.Examplepb.User/1` can be used to do the validation.
``` Elixir
user = Examplepb.User.new()
{:error, _} = ProtoValidator.validate(user)
users = %{user | id: 1}
{:error, _} = ProtoValidator.validate(user)
users = %{user | email: "user@example.com"}
:ok = ProtoValidator.validate(user)
:ok = ProtoValidator.Gen.Examplepb.User.validate(user)
```

## How it works

Refer: https://github.com/envoyproxy/protoc-gen-validate

1. Google's Protobuf messages(like google.protobuf.MessageOptions) are extended with
validating rules(validate.proto)
2. Your protobuf messages can use validate.proto to define validation options
3. This plugin generate validating code when called by protoc. The code can be called
to validate messages
4. Then you can validate your structs
