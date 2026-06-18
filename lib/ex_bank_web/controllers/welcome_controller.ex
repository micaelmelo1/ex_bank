defmodule ExBankWeb.WelcomeController do
  use ExBankWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Welcome to ExBank API"})
  end
end
