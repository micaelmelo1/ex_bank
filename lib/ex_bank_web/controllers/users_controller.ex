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

  def delete(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.delete(id) do
      conn
      |> put_status(:no_content)
      |> render(:delete, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.get(id) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user)
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, %User{} = user} <- Users.update(id, params) do
      conn
      |> put_status(:ok)
      |> render(:update, user: user)
    end
  end
end
