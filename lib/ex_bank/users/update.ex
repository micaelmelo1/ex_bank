defmodule ExBank.Users.Update do
  alias ExBank.Users.User
  alias ExBank.Repo

  def call(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> update(user, params)
    end
  end

  def update(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
