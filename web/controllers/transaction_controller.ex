defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Transaction

  def create(conn, %{"transaction" => transaction_params}) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)
    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Transaction created")
        |> redirect(to: transaction_path(conn, :unmatched))
      {:error, _} ->
        statement_line_id = transaction_params["statement_line_id"]
        conn
        |> put_flash(:error, "Transaction could not be created")
        |> redirect(to: transaction_path(conn, :match, statement_line_id))
    end
  end

  def unmatched(conn, _params) do
    statement_lines = [user_id: conn.assigns.current_user.id]
                      |> StatementLine.unmatched_but_with_possible_expense
                      |> Repo.all
    render(conn, "unmatched.html", statement_lines: statement_lines)
  end

  def match(conn, %{"id" => id}) do
    statement_line = Repo.get(StatementLine, id)
    |> Repo.preload(:payment_method)
    expenses = Repo.all(Expense.potential_matches_for(statement_line: statement_line))
    render(conn, "match.html", statement_line: statement_line, expenses: expenses)
  end
end
