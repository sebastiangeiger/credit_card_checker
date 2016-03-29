defmodule CreditCardChecker.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Hound.Helpers

      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import CreditCardChecker.Router.Helpers

      alias CreditCardChecker.Repo

      # The default endpoint for testing
      @endpoint CreditCardChecker.Endpoint

      hound_session
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(CreditCardChecker.Repo, [])
    end

    :ok
  end
end
