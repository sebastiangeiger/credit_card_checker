defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLine

  def unmatched(conn, _params) do
    statement_lines = Repo.all from sl in StatementLine,
                        join: pm in assoc(sl, :payment_method),
                        where: pm.user_id == ^conn.assigns.current_user.id
    render(conn, "unmatched.html", statement_lines: statement_lines)
  end
end
