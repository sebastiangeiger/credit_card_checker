ExUnit.start

Mix.Task.run "ecto.create", ~w(-r CreditCardChecker.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r CreditCardChecker.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(CreditCardChecker.Repo)

