defmodule ExBank.Users do
  alias ExBank.Users.Create
  alias ExBank.Users.Get
  alias ExBank.Users.Update
  alias ExBank.Users.Delete
  alias ExBank.Users.Verify

  defdelegate create(params), to: Create, as: :call
  defdelegate get(id), to: Get, as: :call
  defdelegate update(id, params), to: Update, as: :call
  defdelegate delete(id), to: Delete, as: :call
  defdelegate login(params), to: Verify, as: :call
end
