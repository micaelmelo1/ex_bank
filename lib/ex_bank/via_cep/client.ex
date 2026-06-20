defmodule ExBank.ViaCep.Client do
  alias ExBank.ViaCep.ClientBehaviour
  @behaviour ClientBehaviour

  @default_url "https://viacep.com.br/ws"

  @impl ClientBehaviour
  def call(url \\ @default_url, zipcode) do
    "#{url}/#{zipcode}/json"
    |> Req.get()
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: %{"erro" => true}}}) do
    {:error, :not_found}
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:ok, %Req.Response{status: 400}}) do
    {:error, :bad_request}
  end

  defp handle_response({:error, _}) do
    {:error, :internal_server_error}
  end
end
