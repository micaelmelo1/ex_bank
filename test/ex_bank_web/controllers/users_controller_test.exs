defmodule ExBankWeb.UsersControllerTest do
  use ExBankWeb.ConnCase, async: true

  import Mox

  alias ExBank.AccountsFixtures
  alias ExBank.Users
  alias Users.User
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

  describe "create/2" do
    test "successfully creates an user", %{
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

      assert %{
               "data" => %{
                 "email" => "john.doe@example.com",
                 "id" => _id,
                 "name" => "John Doe",
                 "zipcode" => "01001000"
               },
               "message" => "User created successfully"
             } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn} do
      params = %{
        "name" => "John Doe",
        "email" => "john.doe@example.com",
        "password" => "123",
        "zipcode" => "12"
      }

      expect(ClientBehaviourMock, :call, fn "12" ->
        {:ok, ""}
      end)

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:unprocessable_entity)

      assert %{
               "errors" => %{
                 "password" => ["should be at least 8 character(s)"],
                 "zipcode" => ["should be 8 character(s)"]
               }
             } = response
    end
  end

  describe "login/2" do
    test "successfully logs in and returns a token", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      expect(ClientBehaviourMock, :call, fn "01001000" ->
        {:ok, expected_response}
      end)

      {:ok, %User{id: id}} = Users.create(params)

      response =
        conn
        |> post(~p"/api/users/login", %{"id" => id, "password" => params["password"]})
        |> json_response(:ok)

      assert %{
               "bearer" => token,
               "message" => "Login successful"
             } = response

      assert is_binary(token)
      assert {:ok, %{user_id: ^id}} = ExBankWeb.Token.verify(token)
    end

    test "returns unauthorized when password is invalid", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      expect(ClientBehaviourMock, :call, fn "01001000" ->
        {:ok, expected_response}
      end)

      {:ok, %User{id: id}} = Users.create(params)

      response =
        conn
        |> post(~p"/api/users/login", %{"id" => id, "password" => "wrong-password"})
        |> json_response(:unauthorized)

      assert %{"errors" => %{"detail" => "Unauthorized"}} = response
    end

    test "returns not_found when user does not exist", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/users/login", %{"id" => 999_999, "password" => "12345678"})
        |> json_response(:not_found)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end
  end

  describe "delete/2" do
    test "successfully deletes an user", %{
      conn: conn,
      params: params,
      expected_response: expected_response
    } do
      zipcode = params["zipcode"]

      expect(ClientBehaviourMock, :call, fn ^zipcode ->
        {:ok, expected_response}
      end)

      {:ok, %User{} = user} = Users.create(params)

      response =
        conn
        |> authenticate_conn(user)
        |> delete(~p"/api/users/#{user.id}")
        |> json_response(:no_content)

      assert %{
               "message" => "User deleted successfully"
             } = response
    end

    test "when there is no user with the given id, returns an error", %{conn: conn} do
      user = AccountsFixtures.user_fixture()

      response =
        conn
        |> authenticate_conn(user)
        |> delete(~p"/api/users/1")
        |> json_response(:not_found)

      assert %{
               "errors" => %{"detail" => "Not Found"}
             } = response
    end
  end
end
