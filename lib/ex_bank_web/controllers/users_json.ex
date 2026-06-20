defmodule ExBankWeb.UsersJSON do
  alias ExBank.Users.User

  def create(%{user: user}) do
    %{
      message: "User created successfully",
      data: data(user)
    }
  end

  def delete(%{user: user}) do
    %{
      message: "User deleted successfully",
      data: data(user)
    }
  end

  def login(%{token: token}) do
    %{
      message: "Login successful",
      bearer: token
    }
  end

  def show(%{user: user}) do
    %{
      data: data(user)
    }
  end

  def update(%{user: user}) do
    %{
      message: "User updated successfully",
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
