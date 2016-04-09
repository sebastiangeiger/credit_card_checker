defmodule CreditCardChecker.PaymentMethodTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.PaymentMethod

  @valid_attrs %{name: "some content", user_id: 123}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PaymentMethod.changeset(%PaymentMethod{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PaymentMethod.changeset(%PaymentMethod{}, @invalid_attrs)
    refute changeset.valid?
  end
end
