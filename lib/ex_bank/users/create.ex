defmodule ExBank.Users.Create do
  alias ExBank.Users.User
  alias ExBank.Repo
  alias ExBank.ViaCep.Client, as: ViaCepClient

  def call(%{"zipcode" => zipcode} = params) do
    with {:ok, _result} <- client().call(zipcode) do
      params
      |> User.changeset()
      |> Repo.insert()
    end
  end

  defp client() do
    Application.get_env(:ex_bank, :via_cep_client, ViaCepClient)
  end
end
