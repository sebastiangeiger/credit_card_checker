defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Transaction

  def create(conn, %{"transaction" => transaction_params}) do
    Transaction.changeset(%Transaction{}, transaction_params)
    |> Repo.insert!
    conn
    |> put_flash(:info, "Transaction created")
    |> redirect(to: transaction_path(conn, :unmatched))
  end

  def unmatched(conn, _params) do
    statement_lines = Repo.all from sl in StatementLine,
                        join: pm in assoc(sl, :payment_method),
                        left_join: t in assoc(sl, :transaction),
                        where: pm.user_id == ^conn.assigns.current_user.id,
                        where: sl.amount_in_cents < 0,
                        where: is_nil(t.id)
    render(conn, "unmatched.html", statement_lines: statement_lines)
  end

  def match(conn, %{"id" => id}) do
    statement_line = Repo.get(StatementLine, id)
    |> Repo.preload(:payment_method)
    expenses = Repo.all from e in Expense,
                order_by: [desc: e.time_of_sale],
                preload: [:merchant, :payment_method]
    render(conn, "match.html", statement_line: statement_line, expenses: expenses)
  end
end
