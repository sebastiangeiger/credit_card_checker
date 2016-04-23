defmodule CreditCardChecker.StatementControllerTest do
  use CreditCardChecker.ConnCase

  alias CreditCardChecker.StatementLine
  import CreditCardChecker.AuthTestHelper, only: [sign_in: 2]

  setup %{conn: conn} do
    user = create_user(%{email: "somebody@example.com", password: "super_secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    payload = %{
      conn: sign_in(conn, user),
      user: user,
      payment_method: payment_method,
    }
    {:ok, payload}
  end

  test "renders form for new resources", %{conn: conn, payment_method: payment_method} do
    conn = get conn, payment_method_statement_path(conn, :new, payment_method)
    assert html_response(conn, 200) =~ ~S{Upload statement for "Visa"}
  end

  test "create statements from a csv file", %{conn: conn, payment_method: payment_method} do
    conn = post conn,
                payment_method_statement_path(conn, :create, payment_method),
                statement: %{file: %Plug.Upload{path: "test/fixtures/format_1.csv"}}

    assert redirected_to(conn) == payment_method_path(conn, :show, payment_method)
    assert Enum.count(Repo.all(StatementLine)) == 4
    assert get_flash(conn, :info) == "Uploaded 4 statement lines"
  end

  test "Re-render if no file given", %{conn: conn, payment_method: payment_method} do
    conn = post conn,
                payment_method_statement_path(conn, :create, payment_method),
                statement: %{}

    assert html_response(conn, 200) =~ "No file given"
  end

  test "Re-render if file does not exist", %{conn: conn, payment_method: payment_method} do
    conn = post conn,
                payment_method_statement_path(conn, :create, payment_method),
                statement: %{file: %Plug.Upload{path: "test/fixtures/does_not_exist.csv"}}

    assert html_response(conn, 200) =~ "No file given"
  end

  test "Re-render if file can't be parsed", %{conn: conn, payment_method: payment_method} do
    conn = post conn,
                payment_method_statement_path(conn, :create, payment_method),
                statement: %{file: %Plug.Upload{path: "test/fixtures/not_a_valid_csv.csv"}}

    assert html_response(conn, 200) =~ "Could not parse file"
  end
end
