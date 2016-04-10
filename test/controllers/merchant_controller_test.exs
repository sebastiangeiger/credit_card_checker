defmodule CreditCardChecker.MerchantControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.Merchant
  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]

  @valid_attrs %{name: "Whole Foods"}
  @invalid_attrs %{name: ""}

  setup %{conn: conn} do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    {:ok, %{conn: sign_in(conn, user), user: user}}
  end

  test "lists my entries on index", %{conn: conn, user: user} do
    create_merchant(@valid_attrs, user: user)
    joe = create_user(%{email: "joe@example.com", password: "super_secret"})
    create_merchant(%{name: "Safeway"}, user: joe)
    conn = get conn, merchant_path(conn, :index)
    assert html_response(conn, 200) =~ "Whole Foods"
    refute html_response(conn, 200) =~ "Safeway"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, merchant_path(conn, :new)
    assert html_response(conn, 200) =~ "New merchant"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, merchant_path(conn, :create), merchant: @valid_attrs
    assert redirected_to(conn) == merchant_path(conn, :index)
    assert Repo.get_by(Merchant, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, merchant_path(conn, :create), merchant: @invalid_attrs
    assert html_response(conn, 200) =~ "New merchant"
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    merchant = create_merchant(@valid_attrs, user: user)
    conn = get conn, merchant_path(conn, :show, merchant)
    assert html_response(conn, 200) =~ "Show merchant"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, merchant_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    merchant = create_merchant(@valid_attrs, user: user)
    conn = get conn, merchant_path(conn, :edit, merchant)
    assert html_response(conn, 200) =~ "Edit merchant"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    merchant = create_merchant(@valid_attrs, user: user)
    conn = put conn, merchant_path(conn, :update, merchant), merchant: @valid_attrs
    assert redirected_to(conn) == merchant_path(conn, :show, merchant)
    assert Repo.get_by(Merchant, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    merchant = create_merchant(@valid_attrs, user: user)
    conn = put conn, merchant_path(conn, :update, merchant), merchant: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit merchant"
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    merchant = create_merchant(@valid_attrs, user: user)
    conn = delete conn, merchant_path(conn, :delete, merchant)
    assert redirected_to(conn) == merchant_path(conn, :index)
    refute Repo.get(Merchant, merchant.id)
  end
end
