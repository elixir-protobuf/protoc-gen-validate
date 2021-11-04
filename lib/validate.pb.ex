defmodule Validate.FieldRules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          type: {atom, any},
          message: Validate.MessageRules.t() | nil
        }
  defstruct [:type, :message]

  oneof :type, 0

  field :message, 17, optional: true, type: Validate.MessageRules
  field :int32, 3, optional: true, type: Validate.Int32Rules, oneof: 0
  field :uint64, 6, optional: true, type: Validate.UInt64Rules, oneof: 0
  field :string, 14, optional: true, type: Validate.StringRules, oneof: 0
  field :repeated, 18, optional: true, type: Validate.RepeatedRules, oneof: 0
end

defmodule Validate.Int32Rules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          lt: integer,
          lte: integer,
          gt: integer,
          gte: integer
        }
  defstruct [:lt, :lte, :gt, :gte]

  field :lt, 2, optional: true, type: :int32
  field :lte, 3, optional: true, type: :int32
  field :gt, 4, optional: true, type: :int32
  field :gte, 5, optional: true, type: :int32
end

defmodule Validate.MessageRules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          required: boolean
        }
  defstruct [:required]

  field :required, 2, optional: true, type: :bool
end

defmodule Validate.UInt64Rules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          lt: non_neg_integer,
          lte: non_neg_integer,
          gt: non_neg_integer,
          gte: non_neg_integer
        }
  defstruct [:lt, :lte, :gt, :gte]

  field :lt, 2, optional: true, type: :uint64
  field :lte, 3, optional: true, type: :uint64
  field :gt, 4, optional: true, type: :uint64
  field :gte, 5, optional: true, type: :uint64
end

defmodule Validate.StringRules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          min_len: non_neg_integer,
          max_len: non_neg_integer
        }
  defstruct [:min_len, :max_len]

  field :min_len, 2, optional: true, type: :uint64
  field :max_len, 3, optional: true, type: :uint64
end

defmodule Validate.RepeatedRules do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          min_items: non_neg_integer,
          max_items: non_neg_integer,
          unique: boolean,
          items: Validate.FieldRules.t() | nil
        }
  defstruct [:min_items, :max_items, :unique, :items]

  field :min_items, 1, optional: true, type: :uint64
  field :max_items, 2, optional: true, type: :uint64
  field :unique, 3, optional: true, type: :bool
  field :items, 4, optional: true, type: Validate.FieldRules
end

defmodule Validate.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend Google.Protobuf.FieldOptions, :rules, 1071, optional: true, type: Validate.FieldRules
end
