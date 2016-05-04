defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense

  def unmatched(conn, _params) do
    statement_lines = Repo.all from sl in StatementLine,
                        join: pm in assoc(sl, :payment_method),
                        where: pm.user_id == ^conn.assigns.current_user.id,
                        where: sl.amount_in_cents < 0
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
