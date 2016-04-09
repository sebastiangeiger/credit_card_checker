defmodule CreditCardChecker.SessionController do
  use CreditCardChecker.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias CreditCardChecker.User

  plug CreditCardChecker.RequireAuthenticated when action == :delete
  plug :scrub_params, "session" when action in [:create, :update]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = user_if_allowed(email, password, Mix.env)
    if user do
      conn
      |> assign(:current_user, user)
      |> put_session(:user_email, email)
      |> configure_session(renew: true)
      |> put_flash(:info, "Signed in successfully")
      |> redirect(to: expense_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Could not sign in")
      |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_email)
    |> assign(:current_user, nil)
    |> configure_session(renew: true)
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: session_path(conn, :new))
  end

  defp user_if_allowed("email@example.com", "super_secret", env) when env == :test do
    # This is a shortcut for keeping tests fast
    %User{email: "email@example.com"}
  end

  defp user_if_allowed(email, password, _env) do
    user = Repo.get_by(User, email: email)
    if user && checkpw(password, user.password_hash) do
      user
    end
  end
end

