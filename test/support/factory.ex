defmodule CreditCardChecker.Factory do

  alias CreditCardChecker.Repo
  alias CreditCardChecker.User
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant

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

  def create_expense(attrs,
                     payment_method: %PaymentMethod{id: payment_method_id},
                     merchant: %Merchant{id: merchant_id},
                     user: %User{id: user_id}) do
    attrs = attrs
    |> Map.put_new(:payment_method_id, payment_method_id)
    |> Map.put_new(:merchant_id, merchant_id)
    |> Map.put_new(:user_id, user_id)
    Expense.changeset(%Expense{}, attrs)
    |> Repo.insert!
  end

  def create_merchant(attrs, user: %User{id: user_id}) do
    attrs = Map.put_new(attrs, :user_id, user_id)
    Merchant.changeset(%Merchant{}, attrs)
    |> Repo.insert!
  end

end
