defmodule ExBank.Users.Create do
  alias ExBank.Users.User
  alias ExBank.Repo

  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end
end
