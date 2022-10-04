defmodule ProtoValidator.Gen.Stringtests.Foo do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.Foo

  validate(:int32, type: :int32, int32: [gte: 0, lte: 10])
end

defmodule ProtoValidator.Gen.Stringtests.Bar do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.Bar

  validate(:uuid, type: :string, string: [ignore_empty: true, well_known: [uuid: true]])
end

defmodule ProtoValidator.Gen.Stringtests.Baz do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.Baz

  validate(:name, type: :string, string: [const: "foo"])
end

defmodule ProtoValidator.Gen.Stringtests.BazLen do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.BazLen

  validate(:name, type: :string, string: [len: 3])
end

defmodule ProtoValidator.Gen.Stringtests.BazLenBytes do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.BazLenBytes

  validate(:name, type: :string, string: [len_bytes: 4])
end

defmodule ProtoValidator.Gen.Stringtests.BazLenBytesMin do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.BazLenBytesMin

  validate(:name, type: :string, string: [min_bytes: 4])
end

defmodule ProtoValidator.Gen.Stringtests.BazLenBytesMax do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.BazLenBytesMax

  validate(:name, type: :string, string: [max_bytes: 8])
end

defmodule ProtoValidator.Gen.Stringtests.BazLenBytesMinMax do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.BazLenBytesMinMax

  validate(:name, type: :string, string: [max_bytes: 8, min_bytes: 4])
end

defmodule ProtoValidator.Gen.Stringtests.StringEqualMinMaxBytes do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringEqualMinMaxBytes

  validate(:val, type: :string, string: [max_bytes: 4, min_bytes: 4])
end

defmodule ProtoValidator.Gen.Stringtests.StringPattern do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringPattern

  validate(:val, type: :string, string: [pattern: "(?i)^[a-z0-9]+$"])
end

defmodule ProtoValidator.Gen.Stringtests.StringPatternEscapes do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringPatternEscapes

  validate(:val, type: :string, string: [pattern: "\\* \\\\ \\w"])
end

defmodule ProtoValidator.Gen.Stringtests.StringPrefix do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringPrefix

  validate(:val, type: :string, string: [prefix: "foo"])
end

defmodule ProtoValidator.Gen.Stringtests.StringSuffix do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringSuffix

  validate(:val, type: :string, string: [suffix: "baz"])
end

defmodule ProtoValidator.Gen.Stringtests.StringContains do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringContains

  validate(:val, type: :string, string: [contains: "bar"])
end

defmodule ProtoValidator.Gen.Stringtests.StringNotContains do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringNotContains

  validate(:val, type: :string, string: [not_contains: "bar"])
end

defmodule ProtoValidator.Gen.Stringtests.StringIn do
  @moduledoc false
  use ProtoValidator, entity: Stringtests.StringIn

  validate(:val, type: :string, string: [in: ["bar", "baz2"]])
end