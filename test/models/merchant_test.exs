defmodule CreditCardChecker.MerchantTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Merchant

  @valid_attrs %{name: "some content", user_id: 123}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Merchant.changeset(%Merchant{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with empty name" do
    changeset = Merchant.changeset(%Merchant{}, %{name: " ", user_id: 123})
    refute changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Merchant.changeset(%Merchant{}, @invalid_attrs)
    refute changeset.valid?
  end
end
