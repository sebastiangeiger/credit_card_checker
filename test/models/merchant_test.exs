defmodule CreditCardChecker.MerchantTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.Merchant
  import CreditCardChecker.Factory,
    only: [create_user: 1, create_merchant: 2]

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

  test "names_for query with merchants for different users" do
    user_1 = create_user(%{email: "user_1@example.com"})
    user_2 = create_user(%{email: "user_2@example.com"})
    create_merchant(%{name: "Merchant #3"}, user: user_1)
    create_merchant(%{name: "Merchant #1"}, user: user_1)
    create_merchant(%{name: "Merchant #2"}, user: user_2)
    create_merchant(%{name: "Merchant #4"}, user: user_1)

    names = Repo.all(Merchant.names_for(user_id: user_1.id))
    assert names == ["Merchant #1", "Merchant #3", "Merchant #4"]
  end
end
