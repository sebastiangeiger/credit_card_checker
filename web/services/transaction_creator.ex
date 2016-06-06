defmodule CreditCardChecker.TransactionCreator do
  alias CreditCardChecker.Transaction
  alias CreditCardChecker.Repo

  def create(transaction_params) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)
    {status, _} = Repo.insert(changeset)
    status
  end
end
