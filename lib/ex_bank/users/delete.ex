defmodule ExBank.Users.Delete do
  alias ExBank.Users.User
  alias ExBank.Repo

  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> delete(user)
    end
  end

  def delete(user) do
    Repo.delete(user)
  end
end
