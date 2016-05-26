defmodule CreditCardChecker.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Hound.Helpers

      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import CreditCardChecker.Router.Helpers

      alias CreditCardChecker.Repo

      @endpoint CreditCardChecker.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CreditCardChecker.Repo)
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(CreditCardChecker.Repo, self())
    Hound.start_session(metadata: metadata)
    :ok
  end
end
