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

```elixir
defmodule User do
  use Protobuf

  field :id, 1, type: :uint64
  field :email, 2, type: :string
end

defmodule ProtoValidator.Gen.User do
  use ProtoValidator

  validate :id, gt: 0
  validate :email, required: true
end

alias ProtoValidator.Gen.User, as: Validator
user = User.new()
{:error, _} = Validator.validate(user)
users = %{user | id: 1}
{:error, _} = Validator.validate(user)
users = %{user | email: "user@example.com"}
:ok = Validator.validate(user)
```

## How it works

Refer: https://github.com/envoyproxy/protoc-gen-validate

1. Google's Protobuf messages(like google.protobuf.MessageOptions) are extended with
validating rules(validate.proto)
2. Your protobuf messages can use validate.proto to define validation options
3. This plugin generate validating code when called by protoc. The code can be called
to validate messages
4. Then you can validate your structs
