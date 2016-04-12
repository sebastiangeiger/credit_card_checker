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
    assert {:ok, _} = Repo.insert(Expense.changeset(%Expense{}, attrs))
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
    assert changeset.valid?
    assert changeset.changes[:amount_in_cents] == 342
  end
end
