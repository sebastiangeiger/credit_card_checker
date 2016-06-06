defmodule CreditCardChecker.TransactionCreatorTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.TransactionCreator
  alias CreditCardChecker.Transaction
  alias CreditCardChecker.Repo

  import CreditCardChecker.Factory

  setup do
    user = create_user(%{email: "somebody@example.com"})
    merchant = create_merchant(%{name: "Whole Foods"}, user: user)
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    statement_line = create_statement_line(%{amount: -3.11, payee: "WHOLFDS"}, payment_method: payment_method)
    expense = create_expense(%{amount: 3.11}, payment_method: payment_method, merchant: merchant, user: user)
    {:ok, %{expense: expense, statement_line: statement_line}}
  end

  test "create with a statement line and an expense", %{statement_line: statement_line, expense: expense} do
    result = TransactionCreator.create(%{
      "expense_id" => expense.id,
      "statement_line_id" => statement_line.id
    })

    assert result == :ok
    transactions = Repo.all(Transaction)
    assert Enum.count(transactions) == 1
    transaction = List.first(transactions)
    assert transaction.expense_id == expense.id
    assert transaction.statement_line_id == statement_line.id
  end

  test "create with a statement line and the wrong expense", %{statement_line: statement_line, expense: expense} do
    result = TransactionCreator.create(%{
      "expense_id" => expense.id + 1,
      "statement_line_id" => statement_line.id
    })

    assert result == :error
    assert Enum.count(Repo.all(Transaction)) == 0
  end
end
