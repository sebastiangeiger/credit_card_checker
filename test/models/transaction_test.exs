defmodule CreditCardChecker.TransactionTest do
  use CreditCardChecker.ModelCase

  import CreditCardChecker.Factory
  alias CreditCardChecker.Transaction
  alias CreditCardChecker.StatementLine

  @valid_attrs %{expense_id: 123, statement_line_id: 456}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "create two transactions with the same expense" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    sl_1 = create_statement_line(%{amount: -12, payee: "Some Payee"},
                                             payment_method: payment_method)
    sl_2 = create_statement_line(%{amount: -20, payee: "Some other Payee"},
                                             payment_method: payment_method)
    expense = create_expense(%{amount: 12}, user: user)
    transaction_1 = Transaction.changeset(%Transaction{},
      %{statement_line_id: sl_1.id, expense_id: expense.id})
    {:ok, _} = Repo.insert(transaction_1)
    transaction_2 = Transaction.changeset(%Transaction{},
      %{statement_line_id: sl_2.id, expense_id: expense.id})
    {:error, changeset} = Repo.insert(transaction_2)
    assert changeset.errors[:expense_id] == "has already been taken"
  end

  test "create two transactions with the same statement_line" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    statement_line = create_statement_line(%{amount: -12, payee: "Some Payee"},
                                             payment_method: payment_method)
    expense_1 = create_expense(%{amount: 12}, user: user)
    expense_2 = create_expense(%{amount: 20}, user: user)
    transaction_1 = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense_1.id})
    {:ok, _} = Repo.insert(transaction_1)
    transaction_2 = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense_2.id})
    {:error, changeset} = Repo.insert(transaction_2)
    assert changeset.errors[:statement_line_id] == "has already been taken"
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
