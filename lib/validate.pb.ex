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
  field :uint64, 6, optional: true, type: Validate.UInt64Rules, oneof: 0
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
          gt: non_neg_integer
        }
  defstruct [:gt]

  field :gt, 4, optional: true, type: :uint64
end
