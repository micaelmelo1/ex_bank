defmodule ExBankWeb.UsersJSON do
  alias ExBank.Users.User

  def create(%{user: user}) do
    %{
      message: "User created successfully",
      data: data(user)
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      zipcode: user.zipcode
    }
  end
end
