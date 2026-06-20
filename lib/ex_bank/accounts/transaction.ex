defmodule ExBank.Accounts.Transaction do
  alias Ecto.Multi
  alias ExBank.Accounts
  alias Accounts.Account
  alias ExBank.Repo

  def call(%{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "amount" => amount
      }) do
    with %Account{} = from_account <- Repo.get(Account, from_account_id),
         %Account{} = to_account <- Repo.get(Account, to_account_id),
         {:ok, amount} <- Decimal.cast(amount) do
      Multi.new()
      |> withdraw(from_account, amount)
      |> deposit(to_account, amount)
      |> Repo.transaction()
      |> handle_transaction(amount)
    else
      nil -> {:error, :not_found}
      :error -> {:error, "Invalid amount"}
    end
  end

  def call(_), do: {:error, :invalid_params}

  defp withdraw(multi, account, amount) do
    new_balance = Decimal.sub(account.balance, amount)
    changeset = Account.changeset(account, %{balance: new_balance})
    Multi.update(multi, :withdraw, changeset)
  end

  defp deposit(multi, account, amount) do
    new_balance = Decimal.add(account.balance, amount)
    changeset = Account.changeset(account, %{balance: new_balance})
    Multi.update(multi, :deposit, changeset)
  end

  defp handle_transaction({:ok, result}, amount), do: {:ok, Map.put(result, :amount, amount)}
  defp handle_transaction({:error, _op, reason, _}, _amount), do: {:error, reason}
end
