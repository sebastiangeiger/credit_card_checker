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
    view_model = params
                 |> translate_match_params
                 |> StatementLineExpenseMatcher.view_model
    render(conn, "match.html", view_model)
  end

  defp translate_match_params(params) do
    case params do
      %{"id" => id, "expense_id" => expense_id} ->
        [statement_line_id: id, expense_id: expense_id, show_new_expense_form: false]
      %{"id" => id, "new" => true} ->
        [statement_line_id: id, expense_id: nil, show_new_expense_form: true]
      %{"id" => id} ->
        [statement_line_id: id, expense_id: nil, show_new_expense_form: false]
    end
  end
end
