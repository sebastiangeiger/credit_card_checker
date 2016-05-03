defmodule CreditCardChecker.TransactionController do
  use CreditCardChecker.Web, :controller

  def unmatched(conn, _params) do
    render(conn, "unmatched.html")
  end
end
