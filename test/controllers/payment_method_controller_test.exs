defmodule CreditCardChecker.PaymentMethodControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.PaymentMethod
  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]

  @valid_attrs %{name: "My Visa Card"}
  @invalid_attrs %{name: ""}

  setup %{conn: conn} do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    {:ok, %{conn: sign_in(conn, user), user: user}}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    create_payment_method(@valid_attrs, user: user)
    joe = create_user(%{email: "joe@example.com", password: "joespass"})
    create_payment_method(%{name: "Joes Visa Card"}, user: joe)
    conn = get conn, payment_method_path(conn, :index)
    assert html_response(conn, 200) =~ "My Visa Card"
    refute html_response(conn, 200) =~ "Joes Visa Card"
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

  test "shows chosen resource", %{conn: conn, user: user} do
    payment_method = create_payment_method(@valid_attrs, user: user)
    conn = get conn, payment_method_path(conn, :show, payment_method)
    assert html_response(conn, 200) =~ "<h2>My Visa Card</h2>"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, payment_method_path(conn, :show, -1)
    end
  end
end
