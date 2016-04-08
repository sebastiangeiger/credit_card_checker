defmodule CreditCardChecker.SessionController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => _password}}) do
    conn
    |> assign(:current_user, %User{email: email})
    |> redirect(to: expense_path(conn, :index))
  end
end

