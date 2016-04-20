defmodule CreditCardChecker.StatementLineTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.StatementLine

  @valid_attrs %{address: "some content", amount_in_cents: 42, payee: "some content", posted_date: "2010-04-17", reference_number: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @invalid_attrs)
    refute changeset.valid?
  end
end
