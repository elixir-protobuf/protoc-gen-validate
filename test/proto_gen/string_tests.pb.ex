defmodule Stringtests.Foo do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :int32, 1, type: :int32, deprecated: false
end

defmodule Stringtests.Bar do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :uuid, 1, type: :string, deprecated: false
end

defmodule Stringtests.Baz do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.BazLen do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.BazLenBytes do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.BazLenBytesMin do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.BazLenBytesMax do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.BazLenBytesMinMax do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringEqualMinMaxBytes do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringPattern do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringPatternEscapes do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringPrefix do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringSuffix do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringContains do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringNotContains do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end

defmodule Stringtests.StringIn do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :val, 1, type: :string, deprecated: false
end