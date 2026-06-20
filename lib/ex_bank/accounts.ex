defmodule ExBank.Accounts do
  alias ExBank.Accounts.Create
  alias ExBank.Accounts.Transaction

  defdelegate create(params), to: Create, as: :call
  defdelegate transaction(params), to: Transaction, as: :call
end
