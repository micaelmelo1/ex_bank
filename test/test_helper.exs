# <- Add this
Mox.defmock(ExBank.ViaCep.ClientBehaviourMock, for: ExBank.ViaCep.ClientBehaviour)
# <- Add this
Application.put_env(:ex_bank, :via_cep_client, ExBank.ViaCep.ClientBehaviourMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ExBank.Repo, :manual)
