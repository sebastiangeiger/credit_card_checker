defmodule CreditCardChecker.ExpenseFormTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.ExpenseForm
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.Repo
  import CreditCardChecker.Factory

  @valid_attrs %{"amount" => "42.31", "time_of_sale" => "2010-04-17 14:00:00"}
  @invalid_attrs %{"time_of_sale" => "2010-04-17 14:00:00"}

  test "insert with a new merchant" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @valid_attrs
    |> Map.put("merchant_name", "Whole Foods")
    |> Map.put("payment_method_id", payment_method.id)
    {:ok, _} = ExpenseForm.insert(attrs, user: user)
    assert Enum.count(Repo.all(Expense)) == 1
    assert Enum.count(Repo.all(Merchant)) == 1
    assert Repo.one!(Expense).amount_in_cents == 4231
  end

  test "insert with an existing merchant" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    create_merchant(%{name: "Whole Foods"}, user: user)
    attrs = @valid_attrs
    |> Map.put("merchant_name", "Whole Foods")
    |> Map.put("payment_method_id", payment_method.id)
    {:ok, _} = ExpenseForm.insert(attrs, user: user)
    assert Enum.count(Repo.all(Expense)) == 1
    assert Enum.count(Repo.all(Merchant)) == 1
  end

  test "insert with an existing merchant for a different user" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    create_merchant(%{name: "Whole Foods"}, user: joe)
    attrs = @valid_attrs
    |> Map.put("merchant_name", "Whole Foods")
    |> Map.put("payment_method_id", payment_method.id)
    {:ok, _} = ExpenseForm.insert(attrs, user: user)
    assert Enum.count(Repo.all(Expense)) == 1
    assert Enum.count(Repo.all(Merchant)) == 2
  end

  test "insert with an invalid merchant" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @valid_attrs
    |> Map.put("merchant_name", "")
    |> Map.put("payment_method_id", payment_method.id)
    {:error, _} = ExpenseForm.insert(attrs, user: user)
    assert Enum.count(Repo.all(Expense)) == 0
    assert Enum.count(Repo.all(Merchant)) == 0
  end

  test "insert with an invalid expense does not create expense or merchant" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @invalid_attrs
    |> Map.put("merchant_name", "Whole Foods")
    |> Map.put("payment_method_id", payment_method.id)
    {:error, _} = ExpenseForm.insert(attrs, user: user)
    assert Enum.count(Repo.all(Expense)) == 0
    assert Enum.count(Repo.all(Merchant)) == 0
  end

  test "insert with an invalid expense returns changeset as second argument" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @invalid_attrs
    |> Map.put("merchant_name", "Whole Foods")
    |> Map.put("payment_method_id", payment_method.id)
    {:error, changeset} = ExpenseForm.insert(attrs, user: user)
    assert Keyword.get(changeset.errors, :amount) == {"can't be blank", []}
    assert changeset.changes[:payment_method_id] == payment_method.id
    assert changeset.changes[:merchant_name] == "Whole Foods"
  end

  test "insert without merchant name preserves the amount" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @invalid_attrs
    |> Map.put("amount", "123.50")
    |> Map.put("payment_method_id", payment_method.id)
    {:error, changeset} = ExpenseForm.insert(attrs, user: user)
    assert changeset.changes[:amount] == "123.50"
  end

  test "insert with an invalid expense (no merchant) returns changeset as second argument" do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    attrs = @valid_attrs
    |> Map.put("payment_method_id", payment_method.id)
    {:error, changeset} = ExpenseForm.insert(attrs, user: user)
    assert Keyword.get(changeset.errors, :merchant_name) == {"can't be blank", []}
    assert changeset.data
  end
end
