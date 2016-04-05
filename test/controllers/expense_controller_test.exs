defmodule CreditCardChecker.ExpenseControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  @valid_attrs %{amount_in_cents: 42, time_of_sale: "2010-04-17 14:00:00",
                 merchant_id: 123}
  @invalid_attrs %{}

  setup do
    Repo.insert!(%Merchant{name: "Whole Foods", id: 123})
    :ok
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, expense_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing expenses"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, expense_path(conn, :new)
    assert html_response(conn, 200) =~ "New expense"
  end

  test "assigns merchants in the new action", %{conn: conn} do
    conn = get conn, expense_path(conn, :new)
    assert conn.assigns[:merchants] == [{"Whole Foods", 123}]
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, expense_path(conn, :create), expense: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :index)
    assert Repo.get_by(Expense, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, expense_path(conn, :create), expense: @invalid_attrs
    assert html_response(conn, 200) =~ "New expense"
  end

  test "shows chosen resource", %{conn: conn} do
    expense = Repo.insert! %Expense{}
    conn = get conn, expense_path(conn, :show, expense)
    assert html_response(conn, 200) =~ "Show expense"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, expense_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    expense = Repo.insert! %Expense{}
    conn = get conn, expense_path(conn, :edit, expense)
    assert html_response(conn, 200) =~ "Edit expense"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    expense = Repo.insert! %Expense{}
    conn = put conn, expense_path(conn, :update, expense), expense: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :show, expense)
    assert Repo.get_by(Expense, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    expense = Repo.insert! %Expense{}
    conn = put conn, expense_path(conn, :update, expense), expense: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit expense"
  end

  test "deletes chosen resource", %{conn: conn} do
    expense = Repo.insert! %Expense{}
    conn = delete conn, expense_path(conn, :delete, expense)
    assert redirected_to(conn) == expense_path(conn, :index)
    refute Repo.get(Expense, expense.id)
  end
end
