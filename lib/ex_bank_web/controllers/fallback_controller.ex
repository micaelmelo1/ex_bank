defmodule ExBankWeb.FallbackController do
  use ExBankWeb, :controller

  def call(conn, {:error, changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ExBankWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
