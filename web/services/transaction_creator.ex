defmodule CreditCardChecker.TransactionCreator do
  alias CreditCardChecker.Transaction
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Repo

  def create(%{"expense_id" => _, "statement_line_id" => _} = transaction_params) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)
    {status, _} = Repo.insert(changeset)
    status
  end

  def create(%{"merchant_name" => merchant_name, "statement_line_id" => statement_line_id}) do
    # TODO: Use `with` here?
    statement_line = Repo.get!(StatementLine, statement_line_id)
                     |> Repo.preload(:payment_method)
    user_id = statement_line.payment_method.user_id #TODO: Needs to be compared to current user_id
    with {:ok, merchant} <- create_or_find_merchant(name: merchant_name, user_id: user_id),
         {:ok, expense} <- Expense.changeset(%Expense{}, %{
                             merchant_id: merchant.id,
                             payment_method_id: statement_line.payment_method_id,
                             amount_in_cents: -1 * statement_line.amount_in_cents,
                             user_id: user_id,
                             time_of_sale: midnight_on(statement_line.posted_date)
                           })
                           |> Repo.insert,
         {:ok, transaction} <- Transaction.changeset(%Transaction{}, %{
                                 expense_id: expense.id,
                                 statement_line_id: statement_line.id
                               })
                               |> Repo.insert,
      do: :ok,
      else: :error
  end

  defp midnight_on(date) do
    Ecto.DateTime.from_date(date)
  end

  defp create_or_find_merchant(name: name, user_id: user_id) do
    merchant = Repo.get_by(Merchant, name: name, user_id: user_id)
    if merchant do
      {:ok, merchant}
    else
      Repo.insert(%Merchant{user_id: user_id, name: name})
    end
  end
end
