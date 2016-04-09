defmodule CreditCardChecker.Factory do

  alias CreditCardChecker.Repo
  alias CreditCardChecker.User
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.Expense

  def create_user(%{email: _, password: _} = credentials) do
    %User{}
    |> User.changeset(credentials)
    |> Repo.insert!
  end

  def create_payment_method(attrs, user: %User{id: user_id}) when user_id != nil do
    attrs = Map.put_new(attrs, :user_id, user_id)
    PaymentMethod.changeset(%PaymentMethod{}, attrs)
    |> Repo.insert!
  end

  def create_expense(attrs, payment_method: %PaymentMethod{id: payment_method_id}) when payment_method_id != nil do
    attrs = Map.put_new(attrs, :payment_method_id, payment_method_id)
    Expense.changeset(%Expense{}, attrs)
    |> Repo.insert!
  end
end
