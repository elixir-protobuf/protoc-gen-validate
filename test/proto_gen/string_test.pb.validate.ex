defmodule ProtoValidator.Gen.StringTest.Uuid do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Uuid

  validate(:uuid, type: :string, string: [ignore_empty: true, well_known: [uuid: true]])
end

defmodule ProtoValidator.Gen.StringTest.Const do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Const

  validate(:name, type: :string, string: [const: "foo"])
end

defmodule ProtoValidator.Gen.StringTest.Len do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Len

  validate(:name, type: :string, string: [len: 3])
end

defmodule ProtoValidator.Gen.StringTest.LenBytes do
  @moduledoc false
  use ProtoValidator, entity: StringTest.LenBytes

  validate(:name, type: :string, string: [len_bytes: 4])
end

defmodule ProtoValidator.Gen.StringTest.MinBytes do
  @moduledoc false
  use ProtoValidator, entity: StringTest.MinBytes

  validate(:name, type: :string, string: [min_bytes: 4])
end

defmodule ProtoValidator.Gen.StringTest.MaxBytes do
  @moduledoc false
  use ProtoValidator, entity: StringTest.MaxBytes

  validate(:name, type: :string, string: [max_bytes: 8])
end

defmodule ProtoValidator.Gen.StringTest.MinMaxBytes do
  @moduledoc false
  use ProtoValidator, entity: StringTest.MinMaxBytes

  validate(:name, type: :string, string: [max_bytes: 8, min_bytes: 4])
end

defmodule ProtoValidator.Gen.StringTest.MinMaxBytesEqual do
  @moduledoc false
  use ProtoValidator, entity: StringTest.MinMaxBytesEqual

  validate(:val, type: :string, string: [max_bytes: 4, min_bytes: 4])
end

defmodule ProtoValidator.Gen.StringTest.Pattern do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Pattern

  validate(:val, type: :string, string: [pattern: "(?i)^[a-z0-9]+$"])
end

defmodule ProtoValidator.Gen.StringTest.PatternEscapes do
  @moduledoc false
  use ProtoValidator, entity: StringTest.PatternEscapes

  validate(:val, type: :string, string: [pattern: "\\* \\\\ \\w"])
end

defmodule ProtoValidator.Gen.StringTest.Prefix do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Prefix

  validate(:val, type: :string, string: [prefix: "foo"])
end

defmodule ProtoValidator.Gen.StringTest.Suffix do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Suffix

  validate(:val, type: :string, string: [suffix: "baz"])
end

defmodule ProtoValidator.Gen.StringTest.Contains do
  @moduledoc false
  use ProtoValidator, entity: StringTest.Contains

  validate(:val, type: :string, string: [contains: "bar"])
end

defmodule ProtoValidator.Gen.StringTest.NotContains do
  @moduledoc false
  use ProtoValidator, entity: StringTest.NotContains

  validate(:val, type: :string, string: [not_contains: "bar"])
end

defmodule ProtoValidator.Gen.StringTest.In do
  @moduledoc false
  use ProtoValidator, entity: StringTest.In

  validate(:val, type: :string, string: [in: ["bar", "baz2"]])
end