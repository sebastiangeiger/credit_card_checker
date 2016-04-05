defmodule CreditCardChecker.PageController do
  use CreditCardChecker.Web, :controller

  def index(conn, _params) do
    redirect conn, to: "/expenses"
  end
end
