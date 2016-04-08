defmodule CreditCardChecker.SessionController do
  use CreditCardChecker.Web, :controller

  def new(conn, _params) do
    text conn, "Sign In"
  end
end

