defmodule ExBankWeb.Token do
  alias ExBankWeb.Endpoint
  alias Phoenix.Token

  @salt "salt_for_token"

  def sign(user) do
    Token.sign(Endpoint, @salt, %{user_id: user.id})
  end

  def verify(token), do: Token.verify(Endpoint, @salt, token, max_age: 86400)
end
