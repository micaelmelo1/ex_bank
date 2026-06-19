defmodule ExBank.Users.Get do
  alias ExBank.Users.User
  alias ExBank.Repo

  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
