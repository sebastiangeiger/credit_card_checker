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
      |> put_session(:user_email, email)
      |> configure_session(renew: true)
      |> put_flash(:info, "Signed in successfully")
      |> redirect(to: expense_path(conn, :index))
    else
      conn
      |> render("new.html")
    end
  end

  def delete(conn, _params) do
    if get_session(conn, :user_email) do
      conn
      |> delete_session(:user_email)
      |> assign(:current_user, nil)
      |> configure_session(renew: true)
      |> put_flash(:info, "Signed out successfully")
    else
      conn
      |> put_flash(:error, "You were never signed in")
    end
    |> redirect(to: session_path(conn, :new))
  end
end

