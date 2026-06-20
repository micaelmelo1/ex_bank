defmodule ExBank.Accounts.Create do
  alias ExBank.Accounts.Account
  alias ExBank.Repo
  alias ExBank.Users
  alias ExBank.Users.User

  def call(params) do
    with {:ok, %User{} = _user} <- Users.get(params["user_id"]) do
      params
      |> Account.changeset()
      |> Repo.insert()
    end
  end
end
