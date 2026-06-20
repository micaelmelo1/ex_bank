defmodule ExBankWeb.AuthTest do
  use ExBankWeb.ConnCase, async: true

  import Mox

  alias ExBank.AccountsFixtures
  alias ExBank.Users
  alias ExBank.ViaCep.ClientBehaviourMock

  setup :verify_on_exit!

  setup do
    params = %{
      "name" => "John Doe",
      "email" => "john.doe@example.com",
      "password" => "12345678",
      "zipcode" => "01001000"
    }

    expected_response = %{
      "bairro" => "Sé",
      "cep" => "01001-000",
      "complemento" => "lado ímpar",
      "ddd" => "11",
      "estado" => "São Paulo",
      "gia" => "1004",
      "ibge" => "3550308",
      "localidade" => "São Paulo",
      "logradouro" => "Praça da Sé",
      "regiao" => "Sudeste",
      "siafi" => "7107",
      "uf" => "SP",
      "unidade" => ""
    }

    {:ok, params: params, expected_response: expected_response}
  end

  describe "protected routes" do
    test "returns unauthorized without token", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/1")
        |> json_response(:unauthorized)

      assert %{"errors" => %{"detail" => "Unauthorized"}} = response
    end

    test "returns unauthorized with invalid token", %{conn: conn} do
      response =
        conn
        |> put_req_header("authorization", "Bearer invalid-token")
        |> get(~p"/api/users/1")
        |> json_response(:unauthorized)

      assert %{"errors" => %{"detail" => "Unauthorized"}} = response
    end

    test "allows access with valid token", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      expect(ClientBehaviourMock, :call, fn "01001000" ->
        {:ok, expected_response}
      end)

      {:ok, user} = Users.create(params)

      response =
        conn
        |> authenticate_conn(user)
        |> get(~p"/api/users/#{user.id}")
        |> json_response(:ok)

      assert %{
               "data" => %{
                 "email" => "john.doe@example.com",
                 "id" => id,
                 "name" => "John Doe",
                 "zipcode" => "01001000"
               }
             } = response

      assert id == user.id
    end

    test "requires authentication for account routes", %{conn: conn} do
      user = AccountsFixtures.user_fixture()

      response =
        conn
        |> post(~p"/api/accounts", %{"user_id" => user.id, "balance" => "100.00"})
        |> json_response(:unauthorized)

      assert %{"errors" => %{"detail" => "Unauthorized"}} = response
    end
  end

  describe "public routes" do
    test "does not require authentication to create user", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      expect(ClientBehaviourMock, :call, fn "01001000" ->
        {:ok, expected_response}
      end)

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:created)

      assert %{"message" => "User created successfully"} = response
    end

    test "does not require authentication to login", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      expect(ClientBehaviourMock, :call, fn "01001000" ->
        {:ok, expected_response}
      end)

      {:ok, user} = Users.create(params)

      response =
        conn
        |> post(~p"/api/users/login", %{"id" => user.id, "password" => params["password"]})
        |> json_response(:ok)

      assert %{"bearer" => token, "message" => "Login successful"} = response
      assert is_binary(token)
    end
  end
end
