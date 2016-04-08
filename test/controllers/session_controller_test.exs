defmodule CreditCardChecker.SessionControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.Session
  @valid_attrs %{email: "email@example.com", password: "super_secret"}
  @invalid_attrs %{}

  test "renders form for sign in", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Sign In"
  end

  test "creating session redirects you to expense index", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :index)
  end
end
