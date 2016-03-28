defmodule CreditCardChecker.ExpenseTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Expense

  @valid_attrs %{amount_in_cents: 42, time_of_sale: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Expense.changeset(%Expense{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Expense.changeset(%Expense{}, @invalid_attrs)
    refute changeset.valid?
  end
end
