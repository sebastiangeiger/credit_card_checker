defmodule CreditCardChecker.SessionControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.Session
  @valid_attrs %{name: "Whole Foods"}
  @invalid_attrs %{}

  test "renders form for sign in", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert text_response(conn, 200) =~ "Sign In"
  end
end
