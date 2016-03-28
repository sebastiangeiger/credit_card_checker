defmodule CreditCardChecker.PaymentMethodControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.PaymentMethod
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, payment_method_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing payment methods"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, payment_method_path(conn, :new)
    assert html_response(conn, 200) =~ "New payment method"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, payment_method_path(conn, :create), payment_method: @valid_attrs
    assert redirected_to(conn) == payment_method_path(conn, :index)
    assert Repo.get_by(PaymentMethod, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, payment_method_path(conn, :create), payment_method: @invalid_attrs
    assert html_response(conn, 200) =~ "New payment method"
  end

  test "shows chosen resource", %{conn: conn} do
    payment_method = Repo.insert! %PaymentMethod{}
    conn = get conn, payment_method_path(conn, :show, payment_method)
    assert html_response(conn, 200) =~ "Show payment method"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, payment_method_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    payment_method = Repo.insert! %PaymentMethod{}
    conn = get conn, payment_method_path(conn, :edit, payment_method)
    assert html_response(conn, 200) =~ "Edit payment method"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    payment_method = Repo.insert! %PaymentMethod{}
    conn = put conn, payment_method_path(conn, :update, payment_method), payment_method: @valid_attrs
    assert redirected_to(conn) == payment_method_path(conn, :show, payment_method)
    assert Repo.get_by(PaymentMethod, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    payment_method = Repo.insert! %PaymentMethod{}
    conn = put conn, payment_method_path(conn, :update, payment_method), payment_method: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit payment method"
  end

  test "deletes chosen resource", %{conn: conn} do
    payment_method = Repo.insert! %PaymentMethod{}
    conn = delete conn, payment_method_path(conn, :delete, payment_method)
    assert redirected_to(conn) == payment_method_path(conn, :index)
    refute Repo.get(PaymentMethod, payment_method.id)
  end
end
