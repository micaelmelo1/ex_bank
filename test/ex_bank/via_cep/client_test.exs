defmodule ExBank.ViaCep.ClientTest do
  use ExUnit.Case

  alias ExBank.ViaCep.Client

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "call/1" do
    test "successfully returns zipcode info", %{bypass: bypass} do
      zipcode = "01001000"

      body = ~s({
        "cep": "01001000",
        "logradouro": "Praça da Sé",
        "bairro": "Sé",
        "localidade": "São Paulo",
        "uf": "SP"
      })

      expected_response =
        {:ok,
         %{
           "bairro" => "Sé",
           "cep" => "01001000",
           "localidade" => "São Paulo",
           "logradouro" => "Praça da Sé",
           "uf" => "SP"
         }}

      Bypass.expect(bypass, "GET", "/#{zipcode}/json", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, body)
      end)

      response =
        bypass.port
        |> endpoint_url()
        |> Client.call(zipcode)

      assert response == expected_response
    end

    test "returns error when zipcode is invalid", %{bypass: bypass} do
      zipcode = "01001000"

      Bypass.expect(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(400, "{\"erro\": true}")
      end)

      response =
        bypass.port
        |> endpoint_url()
        |> Client.call(zipcode)

      assert response == {:error, :bad_request}
    end

    defp endpoint_url(port), do: "http://localhost:#{port}"
  end
end
