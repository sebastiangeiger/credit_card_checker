defmodule CreditCardChecker.TransactionTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Transaction

  @valid_attrs %{expense_id: 123, statement_line_id: 456}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
