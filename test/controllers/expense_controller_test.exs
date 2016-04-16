defmodule CreditCardChecker.ExpenseControllerTest do
  use CreditCardChecker.ConnCase

  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]

  alias CreditCardChecker.Expense

  @valid_attrs %{amount_in_cents: 42, time_of_sale: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payload = %{
      conn: sign_in(conn, user),
      user: user,
      payment_method: create_payment_method(%{name: "Visa"}, user: user),
      merchant: create_merchant(%{name: "Whole Foods"}, user: user)
    }
    {:ok, payload}
  end

  test "lists all entries on index", %{conn: conn, payment_method: payment_method, merchant: merchant, user: user} do
    create_expense(@valid_attrs, payment_method: payment_method,
                   merchant: merchant, user: user)
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    create_expense(%{amount_in_cents: 33, time_of_sale: "2010-04-17 14:00:00"},
                    user: joe)
    conn = get conn, expense_path(conn, :index)
    assert html_response(conn, 200) =~ "$0.42"
    refute html_response(conn, 200) =~ "$0.33"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, expense_path(conn, :new)
    assert html_response(conn, 200) =~ "New expense"
  end

  test "assigns merchants in the new action", %{conn: conn, merchant: merchant} do
    conn = get conn, expense_path(conn, :new)
    assert conn.assigns[:merchants] == [{"Whole Foods", merchant.id}]
  end

  test "creates resource and redirects when data is valid", %{conn: conn, payment_method: payment_method, merchant: merchant, user: user} do
    attrs = @valid_attrs
    |> Map.put_new(:payment_method_id, payment_method.id)
    |> Map.put_new(:merchant_id, merchant.id)
    |> Map.put_new(:user_id, user.id)
    conn = post conn, expense_path(conn, :create), expense: attrs
    assert redirected_to(conn) == expense_path(conn, :index)
    assert Repo.get_by(Expense, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, expense_path(conn, :create), expense: @invalid_attrs
    assert html_response(conn, 200) =~ "New expense"
  end

  test "shows chosen resource", %{conn: conn, payment_method: payment_method, merchant: merchant, user: user} do
    expense = create_expense(@valid_attrs, payment_method: payment_method, merchant: merchant, user: user)
    conn = get conn, expense_path(conn, :show, expense)
    assert html_response(conn, 200) =~ "Show expense"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, expense_path(conn, :show, -1)
    end
  end

  test "deletes chosen resource", %{conn: conn, payment_method: payment_method, merchant: merchant, user: user} do
    expense = create_expense(@valid_attrs, payment_method: payment_method, merchant: merchant, user: user)
    conn = delete conn, expense_path(conn, :delete, expense)
    assert redirected_to(conn) == expense_path(conn, :index)
    refute Repo.get(Expense, expense.id)
  end
end
