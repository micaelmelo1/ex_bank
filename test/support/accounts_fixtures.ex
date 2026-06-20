defmodule ExBank.AccountsFixtures do
  @moduledoc false

  alias ExBank.Accounts
  alias ExBank.Repo
  alias ExBank.Users.User

  def user_fixture(attrs \\ %{}) do
    unique = System.unique_integer([:positive])

    defaults = %{
      "name" => "User #{unique}",
      "email" => "user#{unique}@example.com",
      "password" => "12345678",
      "zipcode" => "12345678"
    }

    defaults
    |> Map.merge(Enum.into(attrs, %{}))
    |> then(&User.changeset/1)
    |> Repo.insert!()
  end

  def account_fixture(%User{id: user_id}, attrs \\ %{}) do
    defaults = %{"user_id" => user_id, "balance" => "100.00"}

    attrs =
      defaults
      |> Map.merge(Enum.into(attrs, %{}))

    {:ok, account} = Accounts.create(attrs)
    account
  end
end
