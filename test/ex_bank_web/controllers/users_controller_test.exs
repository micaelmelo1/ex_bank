defmodule ExBankWeb.UsersControllerTest do
  use ExBankWeb.ConnCase, async: true

  alias ExBank.Users
  alias Users.User

  describe "create/2" do
    test "successfully creates an user", %{conn: conn} do
      params = %{
        name: "John Doe",
        email: "john.doe@example.com",
        password: "12345678",
        zipcode: "12345678"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:created)

      assert %{
               "data" => %{
                 "email" => "john.doe@example.com",
                 "id" => _id,
                 "name" => "John Doe",
                 "zipcode" => "12345678"
               },
               "message" => "User created successfully"
             } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn} do
      params = %{
        name: "John Doe",
        email: "john.doe@example.com",
        password: "1",
        zipcode: "12"
      }

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

  describe "delete/2" do
    test "successfully deletes an user", %{conn: conn} do
      params = %{
        name: "John Doe",
        email: "john.doe@example.com",
        password: "12345678",
        zipcode: "12345678"
      }

      {:ok, %User{id: id}} = Users.create(params)

      response =
        conn
        |> delete(~p"/api/users/#{id}")
        |> json_response(:no_content)

      assert %{
               "message" => "User deleted successfully"
             } = response
    end

    test "when there is no user with the given id, returns an error", %{conn: conn} do
      response =
        conn
        |> delete(~p"/api/users/1")
        |> json_response(:not_found)

      assert %{
               "errors" => %{"detail" => "Not Found"}
             } = response
    end
  end
end
