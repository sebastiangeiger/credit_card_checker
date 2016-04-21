defmodule CreditCardChecker.StatementController do
  use CreditCardChecker.Web, :controller
  alias CreditCardChecker.PaymentMethod

  def new(conn, %{"payment_method_id" => payment_method_id}) do
    payment_method = Repo.get(PaymentMethod, payment_method_id)
    render conn, "new.html", payment_method: payment_method
  end

  def create(conn, params) do
    path = params["statement"]["file"].path
    if File.exists?(path) do
      sts = CreditCardChecker.StatementParser.parse(path)
      text conn, inspect(sts)
    else
      text conn, "No file"
    end
  end
end
