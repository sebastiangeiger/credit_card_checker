defmodule CreditCardChecker.UserController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{ "user" => user_params }) do
    changeset = User.changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Created user #{user.email}")
        |> redirect(to: expense_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Could not create user! Please check errors below.")
        |> render("new.html", changeset: changeset)
    end
  end
end
