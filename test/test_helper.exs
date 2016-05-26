Application.ensure_all_started(:hound)

ExUnit.start(timeout: 10_000)

Ecto.Adapters.SQL.Sandbox.mode(CreditCardChecker.Repo, :manual)
