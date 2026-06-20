defmodule ExBankWeb.Plugs.AuthTest do
  use ExBank.DataCase, async: true

  import Plug.Conn
  import Plug.Test

  alias ExBank.AccountsFixtures
  alias ExBankWeb.Plugs.Auth
  alias ExBankWeb.Token

  @opts Auth.init([])

  defp build_conn do
    conn(:get, "/")
    |> put_private(:phoenix_format, "json")
  end

  describe "call/2" do
    test "assigns user_id when token is valid" do
      user = AccountsFixtures.user_fixture()
      token = Token.sign(user)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token}")
        |> Auth.call(@opts)

      refute conn.halted
      assert conn.assigns.user_id == user.id
    end

    test "halts with 401 when authorization header is missing" do
      conn = build_conn() |> Auth.call(@opts)

      assert conn.halted
      assert conn.status == 401
      assert %{"errors" => %{"detail" => "Unauthorized"}} = Jason.decode!(conn.resp_body)
    end

    test "halts with 401 when token is invalid" do
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer invalid-token")
        |> Auth.call(@opts)

      assert conn.halted
      assert conn.status == 401
      assert %{"errors" => %{"detail" => "Unauthorized"}} = Jason.decode!(conn.resp_body)
    end

    test "halts with 401 when authorization header has wrong format" do
      user = AccountsFixtures.user_fixture()
      token = Token.sign(user)

      conn =
        build_conn()
        |> put_req_header("authorization", token)
        |> Auth.call(@opts)

      assert conn.halted
      assert conn.status == 401
    end
  end
end
