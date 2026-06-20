defmodule ExBankWeb.AccountsControllerTest do
  use ExBankWeb.ConnCase, async: true

  alias ExBank.AccountsFixtures

  describe "create/2" do
    test "successfully creates an account", %{conn: conn} do
      user = AccountsFixtures.user_fixture()

      response =
        conn
        |> post(~p"/api/accounts", %{"user_id" => user.id, "balance" => "150.00"})
        |> json_response(:created)

      assert %{
               "data" => %{
                 "balance" => "150.00",
                 "id" => _id,
                 "user_id" => user_id
               },
               "message" => "Account created successfully"
             } = response

      assert user_id == user.id
    end

    test "returns not_found when user does not exist", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/accounts", %{"user_id" => 999_999, "balance" => "100.00"})
        |> json_response(:not_found)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end

    test "returns validation errors for invalid params", %{conn: conn} do
      user = AccountsFixtures.user_fixture()

      response =
        conn
        |> post(~p"/api/accounts", %{"user_id" => user.id, "balance" => "-1.00"})
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"balance" => ["balance must be positive"]}} = response
    end

    test "returns validation error when user already has an account", %{conn: conn} do
      user = AccountsFixtures.user_fixture()
      AccountsFixtures.account_fixture(user)

      response =
        conn
        |> post(~p"/api/accounts", %{"user_id" => user.id, "balance" => "50.00"})
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"user_id" => ["has already been taken"]}} = response
    end
  end

  describe "transaction/2" do
    test "successfully transfers between accounts", %{conn: conn} do
      from_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "100.00"})

      to_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "25.00"})

      response =
        conn
        |> post(~p"/api/accounts/transaction", %{
          "from_account_id" => from_account.id,
          "to_account_id" => to_account.id,
          "amount" => "40.00"
        })
        |> json_response(:ok)

      assert %{
               "amount" => "40.00",
               "from_account" => %{
                 "balance" => "60.00",
                 "id" => from_id,
                 "user_id" => _
               },
               "message" => "Transaction successful",
               "to_account" => %{
                 "balance" => "65.00",
                 "id" => to_id,
                 "user_id" => _
               }
             } = response

      assert from_id == from_account.id
      assert to_id == to_account.id
    end

    test "returns not_found when account does not exist", %{conn: conn} do
      to_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      response =
        conn
        |> post(~p"/api/accounts/transaction", %{
          "from_account_id" => 999_999,
          "to_account_id" => to_account.id,
          "amount" => "10.00"
        })
        |> json_response(:not_found)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end

    test "returns bad_request when amount is invalid", %{conn: conn} do
      from_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())
      to_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      response =
        conn
        |> post(~p"/api/accounts/transaction", %{
          "from_account_id" => from_account.id,
          "to_account_id" => to_account.id,
          "amount" => "invalid"
        })
        |> json_response(:bad_request)

      assert %{"errors" => %{"detail" => "Invalid amount"}} = response
    end

    test "returns validation error when balance is insufficient", %{conn: conn} do
      from_account =
        AccountsFixtures.account_fixture(AccountsFixtures.user_fixture(), %{"balance" => "20.00"})

      to_account = AccountsFixtures.account_fixture(AccountsFixtures.user_fixture())

      response =
        conn
        |> post(~p"/api/accounts/transaction", %{
          "from_account_id" => from_account.id,
          "to_account_id" => to_account.id,
          "amount" => "50.00"
        })
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"balance" => ["balance must be positive"]}} = response
    end

    test "returns bad_request when params are invalid", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/accounts/transaction", %{"amount" => "10.00"})
        |> json_response(:bad_request)

      assert %{"errors" => %{"detail" => "invalid_params"}} = response
    end
  end
end
