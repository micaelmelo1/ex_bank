defmodule ExBank.Users.VerifyTest do
  use ExBank.DataCase, async: true

  alias ExBank.AccountsFixtures
  alias ExBank.Users

  describe "call/1" do
    test "returns user when credentials are valid" do
      user = AccountsFixtures.user_fixture()

      assert {:ok, returned_user} =
               Users.login(%{"id" => user.id, "password" => "12345678"})

      assert returned_user.id == user.id
    end

    test "returns unauthorized when password is invalid" do
      user = AccountsFixtures.user_fixture()

      assert {:error, :unauthorized} =
               Users.login(%{"id" => user.id, "password" => "wrong-password"})
    end

    test "returns not_found when user does not exist" do
      assert {:error, :not_found} =
               Users.login(%{"id" => 999_999, "password" => "12345678"})
    end
  end
end
