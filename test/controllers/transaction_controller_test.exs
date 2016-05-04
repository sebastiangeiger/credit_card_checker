defmodule CreditCardChecker.TransactionControllerTest do
  use CreditCardChecker.ConnCase

  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]
  alias CreditCardChecker.Transaction

  setup %{conn: conn} do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payload = %{
      conn: sign_in(conn, user),
      user: user,
      payment_method: create_payment_method(%{name: "Visa"}, user: user),
    }
    {:ok, payload}
  end

  test "list all statement lines on unmatched", %{conn: conn, payment_method: payment_method} do
    create_statement_line(%{payee: "Some Payee", amount: -12.34}, payment_method: payment_method)
    conn = get conn, transaction_path(conn, :unmatched)
    assert html_response(conn, 200) =~ "Some Payee"
  end

  test "don't show other users statement lines on unmatched", %{conn: conn} do
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    joes_payment_method = create_payment_method(%{name: "Visa"}, user: joe)
    create_statement_line(%{payee: "Payee for Joe", amount: -12.34},
      payment_method: joes_payment_method)
    conn = get conn, transaction_path(conn, :unmatched)
    refute html_response(conn, 200) =~ "Payee for Joe"
  end

  test "don't show statement lines matched in transactions", %{conn: conn, payment_method: payment_method, user: user} do
    merchant = create_merchant(%{name: "Some Payee"}, user: user)
    statement_line = create_statement_line(%{payee: "Some Payee", amount: -12.34},
                                          payment_method: payment_method)
    expense = create_expense(%{amount: 12.34}, payment_method: payment_method,
                             merchant: merchant, user: user)
    create_transaction(statement_line: statement_line, expense: expense)

    conn = get conn, transaction_path(conn, :unmatched)
    refute html_response(conn, 200) =~ "Some Payee"
  end

  test "don't show matched expenses in match screen", %{conn: conn, payment_method: payment_method, user: user} do
    merchant = create_merchant(%{name: "Some Payee"}, user: user)
    statement_line = create_statement_line(%{payee: "The Payee",
                                             amount: -12.34},
                                          payment_method: payment_method)
    expense = create_expense(%{amount: 12.34}, payment_method: payment_method,
                             merchant: merchant, user: user)
    second_line = create_statement_line(%{payee: "The Other Payee",
                                          amount: -12.34},
                                          payment_method: payment_method)
    create_transaction(statement_line: statement_line, expense: expense)

    conn = get conn, transaction_path(conn, :match, second_line)
    refute html_response(conn, 200) =~ "Some Payee"
  end

  test "creation with valid transaction", %{conn: conn, payment_method: payment_method, user: user} do
    merchant = create_merchant(%{name: "Some Payee"}, user: user)
    statement_line = create_statement_line(%{payee: "The Payee",
                                             amount: -12.34},
                                          payment_method: payment_method)
    expense = create_expense(%{amount: 12.34}, payment_method: payment_method,
                             merchant: merchant, user: user)
    assert Enum.count(Repo.all(Transaction)) == 0
    attrs = %{expense_id: expense.id, statement_line_id: statement_line.id}
    conn = post conn, transaction_path(conn, :create), transaction: attrs
    assert redirected_to(conn) == transaction_path(conn, :unmatched)
    assert get_flash(conn, :info) == "Transaction created"
    assert Enum.count(Repo.all(Transaction)) == 1
  end

  test "creation with invalid transaction", %{conn: conn, payment_method: payment_method, user: user} do
    merchant = create_merchant(%{name: "Some Payee"}, user: user)
    statement_line = create_statement_line(%{payee: "The Payee",
                                             amount: -133},
                                          payment_method: payment_method)
    expense = create_expense(%{amount: 12.34}, payment_method: payment_method,
                             merchant: merchant, user: user)
    assert Enum.count(Repo.all(Transaction)) == 0
    attrs = %{expense_id: expense.id, statement_line_id: statement_line.id}
    conn = post conn, transaction_path(conn, :create), transaction: attrs
    assert redirected_to(conn) == transaction_path(conn, :match, statement_line)
    assert get_flash(conn, :error) == "Transaction could not be created"
    assert Enum.count(Repo.all(Transaction)) == 0
  end
end
