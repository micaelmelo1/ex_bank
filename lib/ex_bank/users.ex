defmodule ExBank.Users do
  alias ExBank.Users.Create

  defdelegate create(params), to: Create, as: :call
end
