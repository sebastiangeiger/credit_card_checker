defmodule CreditCardChecker.TransactionControllerTest do
  use CreditCardChecker.ConnCase

  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]

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
    create_statement_line(%{payee: "Some Payee", amount: 12.34}, payment_method: payment_method)
    conn = get conn, transaction_path(conn, :unmatched)
    assert html_response(conn, 200) =~ "Some Payee"
  end

  test "don't show other users statement lines on unmatched", %{conn: conn} do
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    joes_payment_method = create_payment_method(%{name: "Visa"}, user: joe)
    create_statement_line(%{payee: "Payee for Joe", amount: 12.34},
      payment_method: joes_payment_method)
    conn = get conn, transaction_path(conn, :unmatched)
    refute html_response(conn, 200) =~ "Payee for Joe"
  end
end
