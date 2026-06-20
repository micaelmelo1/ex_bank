defmodule ExBank.Accounts.CreateTest do
  use ExBank.DataCase, async: true

  alias ExBank.Accounts
  alias ExBank.Accounts.Account
  alias ExBank.AccountsFixtures

  describe "call/1" do
    test "creates an account for an existing user" do
      user = AccountsFixtures.user_fixture()

      assert {:ok, %Account{user_id: user_id, balance: balance}} =
               Accounts.create(%{"user_id" => user.id, "balance" => "250.50"})

      assert user_id == user.id
      assert Decimal.eq?(balance, Decimal.new("250.50"))
    end

    test "returns not_found when user does not exist" do
      assert {:error, :not_found} =
               Accounts.create(%{"user_id" => 999_999, "balance" => "100.00"})
    end

    test "returns changeset error when required params are missing" do
      user = AccountsFixtures.user_fixture()

      assert {:error, changeset} = Accounts.create(%{"user_id" => user.id})
      assert "can't be blank" in errors_on(changeset).balance
    end

    test "returns changeset error when balance is negative" do
      user = AccountsFixtures.user_fixture()

      assert {:error, changeset} =
               Accounts.create(%{"user_id" => user.id, "balance" => "-10.00"})

      assert "balance must be positive" in errors_on(changeset).balance
    end

    test "returns changeset error when user already has an account" do
      user = AccountsFixtures.user_fixture()
      AccountsFixtures.account_fixture(user)

      assert {:error, changeset} =
               Accounts.create(%{"user_id" => user.id, "balance" => "50.00"})

      assert "has already been taken" in errors_on(changeset).user_id
    end
  end
end
