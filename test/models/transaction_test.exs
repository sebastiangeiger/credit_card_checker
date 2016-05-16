defmodule CreditCardChecker.TransactionTest do
  use CreditCardChecker.ModelCase

  import CreditCardChecker.Factory
  alias CreditCardChecker.Transaction

  setup do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    records = %{
      user: user,
      payment_method: payment_method,
      merchant: create_merchant(%{name: "Some Merchant"}, user: user),
      statement_line: create_statement_line(%{amount: -12, payee: "Some Payee"},
                                             payment_method: payment_method)
    }
    {:ok, records}
  end

  test "changeset with valid attributes", %{user: user, payment_method: payment_method, merchant: merchant, statement_line: statement_line} do
    expense = create_expense(%{amount: 12}, payment_method: payment_method,
                             merchant: merchant, user: user)
    transaction = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense.id})
    {:ok, _} = Repo.insert(transaction)
  end

  test "create two transactions with the same expense", %{user: user, payment_method: payment_method, merchant: merchant, statement_line: sl_1} do
    sl_2 = create_statement_line(%{amount: -12, payee: "Some other Payee"},
                                             payment_method: payment_method)
    expense = create_expense(%{amount: 12}, payment_method: payment_method,
                               merchant: merchant, user: user)
    transaction_1 = Transaction.changeset(%Transaction{},
      %{statement_line_id: sl_1.id, expense_id: expense.id})
    {:ok, _} = Repo.insert(transaction_1)
    transaction_2 = Transaction.changeset(%Transaction{},
      %{statement_line_id: sl_2.id, expense_id: expense.id})
    {:error, changeset} = Repo.insert(transaction_2)
    assert changeset.errors[:expense_id] == "has already been taken"
  end

  test "create two transactions with the same statement_line", %{user: user, payment_method: payment_method, merchant: merchant, statement_line: statement_line} do
    expense_1 = create_expense(%{amount: 12}, payment_method: payment_method,
                               merchant: merchant, user: user)
    expense_2 = create_expense(%{amount: 12}, payment_method: payment_method,
                               merchant: merchant, user: user)
    transaction_1 = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense_1.id})
    {:ok, _} = Repo.insert(transaction_1)
    transaction_2 = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense_2.id})
    {:error, changeset} = Repo.insert(transaction_2)
    assert changeset.errors[:statement_line_id] == "has already been taken"
  end

  test "create transaction with expense and statement not adding up", %{user: user, payment_method: payment_method, merchant: merchant, statement_line: statement_line} do
    expense = create_expense(%{amount: 13}, payment_method: payment_method,
                             merchant: merchant, user: user)
    transaction = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense.id})
    {:error, changeset} = Repo.insert(transaction)
    assert changeset.errors[:base] == "Amounts of StatementLine and Expense don't add up"
  end

  test "create transaction with expense and statement from different payment methods", %{user: user, merchant: merchant, statement_line: statement_line} do
    payment_method_2 = create_payment_method(%{name: "MasterCard"}, user: user)
    expense = create_expense(%{amount: 12}, payment_method: payment_method_2,
                             merchant: merchant, user: user)
    transaction = Transaction.changeset(%Transaction{},
      %{statement_line_id: statement_line.id, expense_id: expense.id})
    {:error, changeset} = Repo.insert(transaction)
    assert changeset.errors[:base] == "StatementLine and Expense need to belong to same PaymentMethod"
  end
end
