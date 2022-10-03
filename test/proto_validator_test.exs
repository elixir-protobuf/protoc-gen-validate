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
end
