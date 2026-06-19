defmodule ExBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @required_params_create [:name, :email, :password, :zipcode]
  @required_params_update [:name, :email, :zipcode]

  schema "users" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    field :zipcode, :string

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params_create)
    |> do_validations(@required_params_create)
    |> put_password_hash()
  end

  def changeset(user, params) do
    user
    |> cast(params, @required_params_create)
    |> do_validations(@required_params_update)
  end

  defp do_validations(changeset, fields) do
    changeset
    |> validate_required(fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_length(:zipcode, is: 8)
  end

  defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
