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

      Bypass.expect(bypass, "GET", "/01001000/json", fn conn ->
        conn
        |> Plug.Conn.resp(200, "{\"cep\": \"01001000\", \"logradouro\": \"Praça da Sé\", \"bairro\": \"Sé\", \"localidade\": \"São Paulo\", \"uf\": \"SP\"}")
      end)

      response = Client.call(endpoint_url(bypass), zipcode)
      assert response == {:ok, "{\"cep\": \"01001000\", \"logradouro\": \"Praça da Sé\", \"bairro\": \"Sé\", \"localidade\": \"São Paulo\", \"uf\": \"SP\"}"}
    end
  end

  defp endpoint_url(bypass), do: "http://localhost:#{bypass.port}"
end
