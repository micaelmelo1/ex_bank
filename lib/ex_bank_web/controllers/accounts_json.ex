defmodule ExBankWeb.AccountsJSON do
  alias ExBank.Accounts.Account

  def create(%{account: account}) do
    %{
      message: "Account created successfully",
      data: data(account)
    }
  end

  def transaction(%{transaction: %{withdraw: from_account, deposit: to_account, amount: amount}}) do
    %{
      message: "Transaction successful",
      amount: amount,
      from_account: data(from_account),
      to_account: data(to_account)
    }
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      user_id: account.user_id,
      balance: account.balance
    }
  end
end
