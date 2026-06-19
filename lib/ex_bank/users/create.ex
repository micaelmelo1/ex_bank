defmodule ExBank.Users.Create do
  alias ExBank.Users.User
  alias ExBank.Repo
  alias ExBank.ViaCep.Client

  def call(params) do
    changeset = User.changeset(params)

    if changeset.valid? do
      zipcode = Ecto.Changeset.get_field(changeset, :zipcode)

      with {:ok, _} <- Client.call(zipcode),
           {:ok, user} <- Repo.insert(changeset) do
        {:ok, user}
      end
    else
      {:error, changeset}
    end
  end
end
