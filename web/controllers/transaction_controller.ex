defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLineExpenseMatcher
  alias CreditCardChecker.Transaction
  alias CreditCardChecker.UnmatchedStatementLines

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
    view_model = UnmatchedStatementLines.view_model(conn.assigns.current_user.id)
    render(conn, "unmatched.html", view_model)
  end

  def match(conn, params) do
    view_model = case params do
      %{"id" => id, "expense_id" => expense_id} ->
        StatementLineExpenseMatcher.view_model(statement_line_id: id, expense_id: expense_id)
      %{"id" => id} ->
        StatementLineExpenseMatcher.view_model(statement_line_id: id)
    end
    render(conn, "match.html", view_model)
  end
end
