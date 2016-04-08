defmodule CreditCardChecker.SessionController do
  use CreditCardChecker.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, _params) do
    redirect conn, to: expense_path(conn, :index)
  end
end

