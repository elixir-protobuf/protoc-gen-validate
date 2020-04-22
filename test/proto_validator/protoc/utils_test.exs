defmodule ProtoValidator.Protoc.UtilsTest do
  use ExUnit.Case, async: true

  alias ProtoValidator.Protoc.Utils

  describe "test rules string conversion" do
    test "only message rules" do
      rules = %Validate.FieldRules{
        message: %Validate.MessageRules{required: true},
        type: nil
      }

      assert "required: true" == Utils.get_rule_str(rules)
    end

    test "completed rules" do
      rules = %Validate.FieldRules{
        message: %Validate.MessageRules{required: true},
        type: {
          :repeated,
          %Validate.RepeatedRules{
            items: %Validate.FieldRules{
              message: nil,
              type: {:uint64, %Validate.UInt64Rules{gt: 0, lt: 90}}
            },
            max_items: nil,
            min_items: 0,
            unique: true
          }
        }
      }

      assert "required: true, repeated: [items: [uint64: [gt: 0, lt: 90]], min_items: 0, unique: true]" ==
               Utils.get_rule_str(rules)
    end
  end
end
