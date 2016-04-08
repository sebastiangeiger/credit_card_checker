defmodule CreditCardChecker.SessionControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.Session
  alias CreditCardChecker.User
  @valid_attrs %{email: "email@example.com", password: "super_secret"}
  @invalid_attrs %{email: "email@example.com", password: "wrong"}

  test "renders form for sign in", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "<h2>Sign In</h2>"
  end

  test "creating session redirects you to expense index", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :index)
  end

  test "creating session assigns a current user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert Dict.has_key?(conn.assigns, :current_user)
    assert conn.assigns.current_user == %User{email: "email@example.com"}
  end

  test "creating session sets user_email in session", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert get_session(conn, :user_email) == "email@example.com"
  end

  test "can't create a session with wrong password", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert is_nil(conn.assigns.current_user)
    assert is_nil(get_session(conn, :user_email))
    assert html_response(conn, 200) =~ "<h2>Sign In</h2>"
  end
end
