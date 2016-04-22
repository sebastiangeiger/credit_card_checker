defmodule CreditCardChecker.StatementTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Statement
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Repo
  import CreditCardChecker.Factory, only: [create_user: 1, create_payment_method: 2]

  test "it creates all StatementLines when valid" do
    lines = [{1, :valid}, {2, :valid}, {3, :valid}]
            |> Enum.map(&statement_line/1)
    {status, _} = Statement.insert_all(lines)
    assert Enum.count(Repo.all(StatementLine)) == 3
    assert status == :ok
  end

  test "it creates no StatementLines when one is invalid" do
    lines = [{1, :valid}, {2, :invalid}, {3, :valid}]
            |> Enum.map(&statement_line/1)
    {status, reason} = Statement.insert_all(lines)
    assert Enum.count(Repo.all(StatementLine)) == 0
    assert status == :error
    assert reason == :insertion_failed
  end

  defp statement_line({i, :valid}) do
    user = create_user(%{email: "somebody#{i}@example.com", password: "secret"})
    pm = create_payment_method(%{name: "Visa#{i}"}, user: user)
    changes = %{
      amount_in_cents: 732 * i,
      address: "ADDRESS ##{i}",
      payee: "PAYEE ##{i}",
      reference_number: "244921560197198#{i}351539#{i}",
      posted_date: Ecto.Date.cast!({2013, 4, 21}),
      payment_method_id: pm.id
    }
    StatementLine.changeset(%StatementLine{}, changes)
  end

  defp statement_line({i, :invalid}) do
    changes = %{
      amount_in_cents: 732 * i,
      address: "ADDRESS ##{i}",
      payee: "PAYEE ##{i}",
      reference_number: "244921560197198#{i}351539#{i}",
      posted_date: Ecto.Date.cast!({2013, 4, 21})
    }
    StatementLine.changeset(%StatementLine{}, changes)
  end
end
