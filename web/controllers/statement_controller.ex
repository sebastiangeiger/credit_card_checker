defmodule CreditCardChecker.StatementController do
  use CreditCardChecker.Web, :controller
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.StatementParser
  alias CreditCardChecker.Statement

  def new(conn, %{"payment_method_id" => payment_method_id}) do
    payment_method = Repo.get(PaymentMethod, payment_method_id)
    render conn, "new.html", payment_method: payment_method
  end

  def create(conn, %{"payment_method_id" => payment_method_id} = params) do
    payment_method = Repo.get(PaymentMethod, payment_method_id)
    upload = params["statement"]["file"]
    case Statement.parse_and_insert(upload, payment_method_id) do
      {:ok, lines} ->
        conn
        |> put_flash(:info, "Uploaded #{Enum.count(lines)} statement lines")
        |> redirect(to: payment_method_path(conn, :show, payment_method))
      {:error, explanation} ->
        conn
        |> put_flash(:error, explanation)
        |> render("new.html", payment_method: payment_method)
    end
  end
end
