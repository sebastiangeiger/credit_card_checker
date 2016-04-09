defmodule CreditCardChecker.UserController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end
end
