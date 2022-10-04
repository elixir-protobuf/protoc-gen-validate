defmodule ProtoValidator.ProtoValidatorStringTest do
  use ExUnit.Case, async: true

  test "validate integer gte, lte rules" do
    assert :ok = ProtoValidator.validate(%Stringtests.Foo{int32: 0})

    assert {:error, "Invalid int32, should greater than or equal to 0"} =
             ProtoValidator.validate(%Stringtests.Foo{int32: -1})

    assert :ok = ProtoValidator.validate(%Stringtests.Foo{int32: 10})

    assert {:error, "Invalid int32, should less than or equal to 10"} =
             ProtoValidator.validate(%Stringtests.Foo{int32: 11})
  end

  describe "validate string uuid rule" do
    test "should be valid with a nil uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "00000000-0000-0000-0000-000000000000"
               })
    end

    test "should be valid with a v1 uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "b45c0c80-8880-11e9-a5b1-000000000000"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "B45C0C80-8880-11E9-A5B1-000000000000"
               })
    end

    test "should be valid with a v2 uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "b45c0c80-8880-21e9-a5b1-000000000000"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "B45C0C80-8880-21E9-A5B1-000000000000"
               })
    end

    test "should be valid with a v3 uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "a3bb189e-8bf9-3888-9912-ace4e6543002"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "A3BB189E-8BF9-3888-9912-ACE4E6543002"
               })
    end

    test "should be valid with a v4 uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "8b208305-00e8-4460-a440-5e0dcd83bb0a"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "8B208305-00E8-4460-A440-5E0DCD83BB0A"
               })
    end

    test "should be valid with a v5 uuid" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "a6edc906-2f9f-5fb2-a373-efac406f0ef2"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "A6EDC906-2F9F-5FB2-A373-EFAC406F0EF2"
               })
    end

    test "should be invalid with a non-uuid string" do
      assert {:error, "Invalid uuid, must be a valid UUID string in default format"} =
               ProtoValidator.validate(%Stringtests.Bar{uuid: "invalid"})
    end

    test "should be invalid with a bad uuid" do
      assert {:error, "Invalid uuid, must be a valid UUID string in default format"} =
               ProtoValidator.validate(%Stringtests.Bar{
                 uuid: "ffffffff-ffff-ffff-ffff-fffffffffffff"
               })
    end
  end

  describe "validate string const rule" do
    test "should be valid when the value is the same as the declared const" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.Baz{
                 name: "foo"
               })
    end

    test "should be invalid when the value is different as the declared const" do
      assert {:error, "Invalid name, value should be foo"} =
               ProtoValidator.validate(%Stringtests.Baz{
                 name: "bar"
               })
    end
  end

  describe "validate string len rule" do
    test "should be valid when the value has the declared len" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLen{
                 name: "foo"
               })
    end

    test "should be invalid when the value has a different len" do
      assert {:error, "Invalid name, length should be 3"} =
               ProtoValidator.validate(%Stringtests.BazLen{
                 name: "barz"
               })
    end
  end

  describe "validate string len_bytes rule" do
    test "should be valid when the value has the declared len in bytes" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytes{
                 name: "pace"
               })
    end

    test "should be invalid when the value has a different len in bytes" do
      assert {:error, "Invalid name, length bytes should be 4"} =
               ProtoValidator.validate(%Stringtests.BazLenBytes{
                 name: "paces"
               })
    end
  end

  describe "validate string min_bytes rule" do
    test "should be valid when the value has at least the declared len in bytes" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMin{
                 name: "proto"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMin{
                 name: "quux"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMin{
                 name: "你好"
               })
    end

    test "should be invalid when the value has less len in bytes" do
      assert {:error, "Invalid name, byte length must be at least 4"} =
               ProtoValidator.validate(%Stringtests.BazLenBytesMin{
                 name: ""
               })
    end
  end

  describe "validate string max_bytes rule" do
    test "should be valid when the value has at most the declared len in bytes" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMax{
                 name: "foo"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMax{
                 name: "12345678"
               })
    end

    test "should be invalid when the value has more then the declared len in bytes" do
      assert {:error, "Invalid name, byte length must be at most 8"} =
               ProtoValidator.validate(%Stringtests.BazLenBytesMax{
                 name: "123456789"
               })

      assert {:error, "Invalid name, byte length must be at most 8"} =
               ProtoValidator.validate(%Stringtests.BazLenBytesMax{
                 name: "你好你好你好"
               })
    end
  end

  describe "validate both min/max bytes rule" do
    test "should be valid when the value has the bytes len inside the min/max bounds" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "protoc"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "quux"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "fizzbuzz"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "你好"
               })
    end

    test "should be invalid when the value has the bytes len outside the min/max bounds" do
      assert {:error, "Invalid name, byte length must be at least 4"} =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "foo"
               })

      assert {:error, "Invalid name, byte length must be at most 8"} =
               ProtoValidator.validate(%Stringtests.BazLenBytesMinMax{
                 name: "你好你好你"
               })
    end
  end

  describe "validate equal min/max bytes rule" do
    test "should be valid when the values has the len compatible with the same min and max bytes len" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringEqualMinMaxBytes{
                 val: "prot"
               })
    end

    test "should be not valid when the values has the len incompatible with the same min and max bytes len" do
      assert {:error, "Invalid val, byte length must be at most 4"} =
               ProtoValidator.validate(%Stringtests.StringEqualMinMaxBytes{
                 val: "protos"
               })
    end
  end

  describe "validate pattern rule" do
    test "it should be valid when the value matches the pattern" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringPattern{
                 val: "Foo123"
               })
    end

    test "it should not be valid when the value does not match the pattern" do
      assert {:error, "Invalid val, should match the pattern (?i)^[a-z0-9]+$"} =
               ProtoValidator.validate(%Stringtests.StringPattern{
                 val: "!@#$%^&*()"
               })

      assert {:error, "Invalid val, should match the pattern (?i)^[a-z0-9]+$"} =
               ProtoValidator.validate(%Stringtests.StringPattern{
                 val: ""
               })

      assert {:error, "Invalid val, should match the pattern (?i)^[a-z0-9]+$"} =
               ProtoValidator.validate(%Stringtests.StringPattern{
                 val: "a\000"
               })
    end

    test "it should pass when the values matches the pattern, and the pattern has escape chars" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringPatternEscapes{
                 val: "* \\ x"
               })
    end

    test "it should not be valid when the values does not match the pattern and the pattern has escape chars" do
      assert {:error, "Invalid val, should match the pattern \\* \\\\ \\w"} =
               ProtoValidator.validate(%Stringtests.StringPatternEscapes{
                 val: ""
               })

      assert {:error, "Invalid val, should match the pattern \\* \\\\ \\w"} =
               ProtoValidator.validate(%Stringtests.StringPatternEscapes{
                 val: "invalid"
               })
    end
  end

  describe "validate prefix rule" do
    test "should pass when the value has the right prefix" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringPrefix{
                 val: "foobar"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.StringPrefix{
                 val: "foo"
               })
    end

    test "should not pass when the value does not have the right prefix" do
      assert {:error, "Invalid val, should start with foo"} =
               ProtoValidator.validate(%Stringtests.StringPrefix{
                 val: "bar"
               })

      assert {:error, "Invalid val, should start with foo"} =
               ProtoValidator.validate(%Stringtests.StringPrefix{
                 val: "FooBar"
               })
    end
  end

  describe "validate suffix rule" do
    test "should pass when the value has the right suffix" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringSuffix{
                 val: "foobaz"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.StringSuffix{
                 val: "baz"
               })
    end

    test "should not pass when the value does not have the right suffix" do
      assert {:error, "Invalid val, should end with baz"} =
               ProtoValidator.validate(%Stringtests.StringSuffix{
                 val: "foobar"
               })

      assert {:error, "Invalid val, should end with baz"} =
               ProtoValidator.validate(%Stringtests.StringSuffix{
                 val: "FooBaz"
               })
    end
  end

  describe "validate contains rule" do
    test "should pass when the value contains the provided context" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringContains{
                 val: "candy bars"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.StringContains{
                 val: "bar"
               })
    end

    test "should not pass when the value does not contain the provided context" do
      assert {:error, "Invalid val, should contain bar"} =
               ProtoValidator.validate(%Stringtests.StringContains{
                 val: "candy bazs"
               })

      assert {:error, "Invalid val, should contain bar"} =
               ProtoValidator.validate(%Stringtests.StringContains{
                 val: "Candy Bars"
               })
    end
  end

  describe "validate not_contains rule" do
    test "should pass when the value does not contain the provided context" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringNotContains{
                 val: "candy bazs"
               })

      assert :ok =
               ProtoValidator.validate(%Stringtests.StringNotContains{
                 val: "Candy Bars"
               })
    end

    test "should not pass when the value contains the provided context" do
      assert {:error, "Invalid val, should not contain bar"} =
               ProtoValidator.validate(%Stringtests.StringNotContains{
                 val: "candy bars"
               })

      assert {:error, "Invalid val, should not contain bar"} =
               ProtoValidator.validate(%Stringtests.StringNotContains{
                 val: "bar"
               })
    end
  end

  describe "validate in rule" do
    test "should pass when the value is allowed" do
      assert :ok =
               ProtoValidator.validate(%Stringtests.StringIn{
                 val: "bar"
               })
    end

    test "should not pass when the value is not allowed" do
      assert {:error, "Invalid val, value should be oneof [\"bar\", \"baz2\"]"} =
               ProtoValidator.validate(%Stringtests.StringIn{
                 val: "quux"
               })
    end
  end
end
