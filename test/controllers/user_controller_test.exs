defmodule CreditCardChecker.UserControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.User

  @valid_attrs %{email: "somebody@example.com", password: "super_safe"}
  @invalid_attrs %{email: "somebody@example.com"}

  test "can show a registration form" do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "<h2>Register</h2>"
  end

  test "can't register without password" do
    assert Repo.all(User) == []
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>Register</h2>"
    assert Repo.all(User) == []
  end

  test "can register with an email/password" do
    assert Repo.all(User) == []
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert html_response(conn, 302)
    users = Repo.all(User)
    assert Enum.count(users) == 1
    assert List.first(users).email == "somebody@example.com"
  end
end
