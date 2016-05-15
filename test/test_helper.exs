Application.ensure_all_started(:hound)
ExUnit.start(timeout: 10_000)

Mix.Task.run "ecto.create", ~w(-r CreditCardChecker.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r CreditCardChecker.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(CreditCardChecker.Repo)

