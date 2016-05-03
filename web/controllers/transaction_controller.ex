defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.StatementLine

  def unmatched(conn, _params) do
    statement_lines = Repo.all(StatementLine)
    render(conn, "unmatched.html", statement_lines: statement_lines)
  end
end
