defmodule ExBank.ViaCep.ClientBehaviour do
  @callback call(String.t()) :: {:ok, map()} | {:error, :atom}
end
