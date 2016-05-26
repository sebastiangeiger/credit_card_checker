Application.ensure_all_started(:hound)

ExUnit.start(timeout: 10_000)

Ecto.Adapters.SQL.begin_test_transaction(CreditCardChecker.Repo)

