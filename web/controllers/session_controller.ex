defmodule CreditCardChecker.SessionController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    if email == "email@example.com" && password == "super_secret" do
      conn
      |> assign(:current_user, %User{email: email})
      |> redirect(to: expense_path(conn, :index))
    else
      conn
      |> render("new.html")
    end
  end
end

