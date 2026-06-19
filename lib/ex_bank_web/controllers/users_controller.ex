defmodule ExBankWeb.UsersController do
  use ExBankWeb, :controller

  alias ExBank.Users
  alias Users.User

  action_fallback ExBankWeb.FallbackController

  def create(conn, params) do
    with {:ok, %User{} = user} <- Users.create(params) do
      conn
      |> put_status(:created)
      |> render(:create, user: user)
    end
  end
end
