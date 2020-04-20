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
## Notes
Currently only those rules are supported:
``` protobuf
message MessageRules {
    // Required specifies that this field must be set
    optional bool required = 2;
}

// UInt64Rules describes the constraints applied to `uint64` values
message UInt64Rules {
    // Lt specifies that this field must be less than the specified value,
    // exclusive
    optional uint64 lt = 2;
    // Gt specifies that this field must be greater than the specified value,
    // exclusive. If the value of Gt is larger than a specified Lt or Lte, the
    // range is reversed.
    optional uint64 gt = 4;
}
message RepeatedRules {
    // MinItems specifies that this field must have the specified number of
    // items at a minimum
    optional uint64 min_items = 1;

    // MaxItems specifies that this field must have the specified number of
    // items at a maximum
    optional uint64 max_items = 2;

    // Unique specifies that all elements in this field must be unique. This
    // contraint is only applicable to scalar and enum types (messages are not
    // supported).
    optional bool   unique    = 3;

    // Items specifies the contraints to be applied to each item in the field.
    // Repeated message fields will still execute validation against each item
    // unless skip is specified here.
    optional FieldRules items = 4;
}
```

## How it works

Refer: https://github.com/envoyproxy/protoc-gen-validate

1. Google's Protobuf messages(like google.protobuf.MessageOptions) are extended with
validating rules(validate.proto)
2. Your protobuf messages can use validate.proto to define validation options
3. This plugin generate validating code when called by protoc. The code can be called
to validate messages
4. Then you can validate your structs
