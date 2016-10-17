defmodule CreditCardChecker.ExpenseTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Expense
  alias CreditCardChecker.Repo
  import CreditCardChecker.Factory

  @valid_attrs %{amount_in_cents: 42, time_of_sale: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    merchant = create_merchant(%{name: "Whole Foods"}, user: user)
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @valid_attrs
    |> Map.put(:merchant_id, merchant.id)
    |> Map.put(:payment_method_id, payment_method.id)
    |> Map.put(:user_id, user.id)
    {:ok, _} = Repo.insert(Expense.changeset(%Expense{}, attrs))
  end

  test "changeset with somebody else's merchant" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    merchant = create_merchant(%{name: "Some Merchant"}, user: joe)
    payment_method = create_payment_method(%{name: "Some Payment Method"}, user: user)
    attrs = @valid_attrs
    |> Map.put(:user_id, user.id)
    |> Map.put(:merchant_id, merchant.id)
    |> Map.put(:payment_method_id, payment_method.id)
    expense = Expense.changeset(%Expense{}, attrs)
    {:error, changeset} = Repo.insert(expense)
    assert changeset.errors[:merchant_id] == {"does not belong to the current user", []}
  end

  test "changeset with somebody else's payment_method" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    merchant = create_merchant(%{name: "Some Merchant"}, user: user)
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Some Payment Method"}, user: joe)
    attrs = @valid_attrs
    |> Map.put(:user_id, user.id)
    |> Map.put(:merchant_id, merchant.id)
    |> Map.put(:payment_method_id, payment_method.id)
    expense = Expense.changeset(%Expense{}, attrs)
    {:error, changeset} = Repo.insert(expense)
    assert changeset.errors[:payment_method_id] == {"does not belong to the current user", []}
  end

  test "changeset with invalid attributes" do
    changeset = Expense.changeset(%Expense{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with an amount" do
    attrs = %{"time_of_sale" => "2010-04-17 14:00:00", "amount" => "3.42",
              "merchant_id" => "123", "payment_method_id" => "456",
              "user_id" => "789"}
    changeset = Expense.changeset(%Expense{}, attrs)
    assert changeset.changes[:amount_in_cents] == 342
  end
end
