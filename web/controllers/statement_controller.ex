defmodule CreditCardChecker.StatementController do
  use CreditCardChecker.Web, :controller
  def new(conn, _params) do
    text(conn, "Hey there")
  end
end
