defmodule ExBank.Accounts.TransactionTest do
  use ExBank.DataCase, async: true

  alias ExBank.Accounts
  alias ExBank.Accounts.Account
  alias ExBank.AccountsFixtures
  alias ExBank.Repo

  describe "call/1" do
    test "transfers amount between accounts" do
      from_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "100.00"})

      to_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "50.00"})

      assert {:ok, %{withdraw: withdraw, deposit: deposit, amount: amount}} =
               Accounts.transaction(%{
                 "from_account_id" => from_account.id,
                 "to_account_id" => to_account.id,
                 "amount" => "30.00"
               })

      assert Decimal.eq?(amount, Decimal.new("30.00"))
      assert Decimal.eq?(withdraw.balance, Decimal.new("70.00"))
      assert Decimal.eq?(deposit.balance, Decimal.new("80.00"))

      reloaded_from = Repo.get!(Account, from_account.id)
      reloaded_to = Repo.get!(Account, to_account.id)

      assert Decimal.eq?(reloaded_from.balance, Decimal.new("70.00"))
      assert Decimal.eq?(reloaded_to.balance, Decimal.new("80.00"))
    end

    test "returns not_found when from account does not exist" do
      to_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      assert {:error, :not_found} =
               Accounts.transaction(%{
                 "from_account_id" => 999_999,
                 "to_account_id" => to_account.id,
                 "amount" => "10.00"
               })
    end

    test "returns not_found when to account does not exist" do
      from_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      assert {:error, :not_found} =
               Accounts.transaction(%{
                 "from_account_id" => from_account.id,
                 "to_account_id" => 999_999,
                 "amount" => "10.00"
               })
    end

    test "returns error when amount is invalid" do
      from_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())
      to_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      assert {:error, "Invalid amount"} =
               Accounts.transaction(%{
                 "from_account_id" => from_account.id,
                 "to_account_id" => to_account.id,
                 "amount" => "abc"
               })
    end

    test "returns changeset error when balance is insufficient" do
      from_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "50.00"})

      to_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "10.00"})

      assert {:error, %Ecto.Changeset{}} =
               Accounts.transaction(%{
                 "from_account_id" => from_account.id,
                 "to_account_id" => to_account.id,
                 "amount" => "100.00"
               })

      reloaded_from = Repo.get!(Account, from_account.id)
      reloaded_to = Repo.get!(Account, to_account.id)

      assert Decimal.eq?(reloaded_from.balance, Decimal.new("50.00"))
      assert Decimal.eq?(reloaded_to.balance, Decimal.new("10.00"))
    end

    test "returns invalid_params when required params are missing" do
      assert {:error, :invalid_params} =
               Accounts.transaction(%{"from_account_id" => "1", "amount" => "10.00"})
    end
  end
end
