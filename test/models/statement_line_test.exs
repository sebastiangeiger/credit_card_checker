defmodule CreditCardChecker.StatementLineTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.PaymentMethod
  import CreditCardChecker.Factory, only: [create_user: 1,
                                           create_payment_method: 2]

  @valid_attrs %{
    address: "some content", amount_in_cents: 42, payee: "some content",
    posted_date: "2010-04-17", payment_method_id: 123
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "inserting a changeset" do
    changeset = StatementLine.changeset(%StatementLine{},
                                        attrs_with_dependent_records)
    {status, _} = Repo.insert(changeset)
    assert status == :ok
  end

  defp attrs_with_dependent_records do
    user = create_user(%{email: "somebody@example.com", password: "secret"})
    %PaymentMethod{id: pm_id} = create_payment_method(%{name: "Visa"},
                                                              user: user)
    %{ @valid_attrs | payment_method_id: pm_id }
  end
end
