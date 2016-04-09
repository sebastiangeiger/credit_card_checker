defmodule CreditCardChecker.UserControllerTest do
  use CreditCardChecker.ConnCase

  test "can show a registration form" do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "<h2>Register</h2>"
  end
end
