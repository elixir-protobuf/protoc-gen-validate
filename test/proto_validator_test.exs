defmodule ProtoValidator.ProtoValidatorTest do
  use ExUnit.Case, async: true

  describe "all validate methods should work" do
    test "get :ok for valid struct" do
      user = %Examplepb.User{
        id: 10,
        email: "test@example.com",
        gender: :MALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 1888
          }
        ],
        following_ids: [1, 2, 3]
      }

      user_map = %{
        id: 10,
        email: "test@example.com",
        gender: :MALE,
        phones: [
          %{
            phone_number: 1888
          }
        ],
        following_ids: [1, 2, 3]
      }

      assert :ok = ProtoValidator.Gen.Examplepb.User.validate(user)
      assert :ok = ProtoValidator.Gen.Examplepb.User.validate(user_map)
      assert :ok = ProtoValidator.validate(user)
      assert :ok = ProtoValidator.validate(Examplepb.User, user)
    end

    test "validate list data work" do
      user1 = %Examplepb.User{
        id: 10,
        email: "user1@example.com",
        gender: :MALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 1888
          }
        ],
        following_ids: [1, 2, 3]
      }

      user2 = %Examplepb.User{
        id: 11,
        email: "user2@example.com",
        gender: :FEMALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 1999
          }
        ],
        following_ids: [1]
      }

      user3 = %Examplepb.User{
        id: 11,
        email: "user2@example.com",
        gender: :FEMALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 4000
          }
        ],
        following_ids: [1]
      }

      assert :ok == ProtoValidator.validate([user1, user2])

      assert {:error, "Invalid phone_number, should less than 2000"} ==
               ProtoValidator.validate([user1, user2, user3])
    end

    @tag :skip
    # TODO: required option only checks nil or not currently
    test "get :error for valid struct" do
      user = %Examplepb.User{
        id: 10,
        gender: :MALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 1888
          }
        ],
        following_ids: [1, 2, 3]
      }

      user_map = %{
        id: 10,
        gender: :MALE,
        phones: [
          %{
            phone_number: 1888
          }
        ],
        following_ids: [1, 2, 3]
      }

      assert {:error, "Invalid email, should exists"} =
               ProtoValidator.Gen.Examplepb.User.validate(user)

      assert {:error, "Invalid email, should exists"} =
               ProtoValidator.Gen.Examplepb.User.validate(user_map)

      assert {:error, "Invalid email, should exists"} = ProtoValidator.validate(user)

      assert {:error, "Invalid email, should exists"} =
               ProtoValidator.validate(Examplepb.User, user)
    end
  end

  describe "test invalid data" do
    test "got :error number exceeds the specified range" do
      user = %Examplepb.User{
        id: "100",
        email: "example@test.com",
        phones: [
          %Examplepb.Phone{
            phone_number: 1111
          }
        ]
      }

      assert {:error, "\"100\" is not integer"} = ProtoValidator.validate(user)

      user = %{user | id: 100}
      assert {:error, "Invalid id, should less than 90"} = ProtoValidator.validate(user)
    end

    test "got :error when child message is invalid" do
      user = %Examplepb.User{
        id: 10,
        email: "test@example",
        phones: [
          %Examplepb.Phone{
            phone_number: 3000
          }
        ]
      }

      assert {:error, "Invalid phone_number, should less than 2000"} =
               ProtoValidator.validate(user)
    end

    test "repeated message validation works" do
      user = %Examplepb.User{
        id: 10,
        email: "test@example",
        phones: nil
      }

      assert {:error, "Invalid phones, length should greater then 1"} =
               ProtoValidator.validate(user)

      user = %{user | phones: []}

      assert {:error, "Invalid phones, length should greater then 1"} =
               ProtoValidator.validate(user)

      user = %{user | phones: [%Examplepb.Phone{phone_number: 3000}]}

      assert {:error, "Invalid phone_number, should less than 2000"} =
               ProtoValidator.validate(user)
    end

    test "repeated internal type messages validation work" do
      user = %Examplepb.User{
        id: 10,
        email: "test@example.com",
        gender: :MALE,
        phones: [
          %Examplepb.Phone{
            phone_number: 1888
          }
        ],
        following_ids: [100]
      }

      assert {:error, "Invalid following_ids, should less than 90"} ==
               ProtoValidator.validate(user)

      user = %{user | following_ids: [1, 2, "3"]}

      assert {:error, "\"3\" is not integer"} ==
               ProtoValidator.validate(user)

      user = %{user | following_ids: [1, 1, 2]}

      assert {:error, "Invalid following_ids, values should be uniq"} ==
               ProtoValidator.validate(user)
    end
  end

  test "validate string data" do
    user = %Examplepb.User{
      id: 10,
      email: "test@example",
      phones: [
        %Examplepb.Phone{
          phone_number: 1888
        }
      ]
    }

    assert :ok = ProtoValidator.validate(user)

    user = %{user | email: "1"}

    assert {:error, "Invalid email, length must be at least 5"} = ProtoValidator.validate(user)

    user = %{user | email: "1234567890123456789012345678901"}

    assert {:error, "Invalid email, length must be at most 30"} = ProtoValidator.validate(user)

    user = %{user | email: "あいうえお"}
    assert :ok = ProtoValidator.validate(user)

    user = %{user | email: "あいうえ"}

    assert {:error, "Invalid email, length must be at least 5"} = ProtoValidator.validate(user)
  end

  test "validate integer gte, lte rules" do
    assert :ok = ProtoValidator.validate(%Examplepb.Foo{int32: 0})

    assert {:error, "Invalid int32, should greater than or equal to 0"} =
             ProtoValidator.validate(%Examplepb.Foo{int32: -1})

    assert :ok = ProtoValidator.validate(%Examplepb.Foo{int32: 10})

    assert {:error, "Invalid int32, should less than or equal to 10"} =
             ProtoValidator.validate(%Examplepb.Foo{int32: 11})
  end

  describe "validate string uuid rule" do
    test "should be valid with a nil uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "00000000-0000-0000-0000-000000000000"
               })
    end

    test "should be valid with a v1 uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "b45c0c80-8880-11e9-a5b1-000000000000"
               })

      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "B45C0C80-8880-11E9-A5B1-000000000000"
               })
    end

    test "should be valid with a v2 uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "b45c0c80-8880-21e9-a5b1-000000000000"
               })

      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "B45C0C80-8880-21E9-A5B1-000000000000"
               })
    end

    test "should be valid with a v3 uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "a3bb189e-8bf9-3888-9912-ace4e6543002"
               })

      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "A3BB189E-8BF9-3888-9912-ACE4E6543002"
               })
    end

    test "should be valid with a v4 uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "8b208305-00e8-4460-a440-5e0dcd83bb0a"
               })

      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "8B208305-00E8-4460-A440-5E0DCD83BB0A"
               })
    end

    test "should be valid with a v5 uuid" do
      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "a6edc906-2f9f-5fb2-a373-efac406f0ef2"
               })

      assert :ok =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "A6EDC906-2F9F-5FB2-A373-EFAC406F0EF2"
               })
    end

    test "should be invalid with a non-uuid string" do
      assert {:error, "Invalid uuid, must be a valid UUID string in default format"} =
               ProtoValidator.validate(%Examplepb.Bar{uuid: "invalid"})
    end

    test "should be invalid with a bad uuid" do
      assert {:error, "Invalid uuid, must be a valid UUID string in default format"} =
               ProtoValidator.validate(%Examplepb.Bar{
                 uuid: "ffffffff-ffff-ffff-ffff-fffffffffffff"
               })
    end
  end


  describe "validate string const rule" do
    test "should be valid when the value is the same as the declared const" do
      assert :ok =
        ProtoValidator.validate(%Examplepb.Baz{
          name: "foo"
        })
    end

    test "should be invalid when the value is different as the declared const" do
      assert {:error, "Invalid name, value should be foo"} =
        ProtoValidator.validate(%Examplepb.Baz{
          name: "bar"
        })
    end
  end
end
