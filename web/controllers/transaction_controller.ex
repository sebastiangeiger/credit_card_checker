defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.StatementLineExpenseMatcher
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
    unmatched_but_with_possible_expense =
      [user_id: conn.assigns.current_user.id]
      |> StatementLine.unmatched_but_with_possible_expense
      |> Repo.all
    render(conn, "unmatched.html", unmatched_but_with_possible_expense: unmatched_but_with_possible_expense)
  end

  def match(conn, params) do
    view_models = case params do
      %{"id" => id, "expense_id" => expense_id} ->
        StatementLineExpenseMatcher.diff_view(statement_line_id: id, expense_id: expense_id)
      %{"id" => id} ->
        StatementLineExpenseMatcher.diff_view(statement_line_id: id)
    end
    render(conn, "match.html", view_models)
  end
end
