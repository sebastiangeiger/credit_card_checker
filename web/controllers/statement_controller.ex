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
    file = params["statement"]["file"]
    if file do
      {status, lines} = file.path
                        |> StatementParser.parse
                        |> add_payment_method_id(payment_method_id)
                        |> Statement.insert_all
      conn
      |> put_flash(:info, "Uploaded #{Enum.count(lines)} statement lines")
      |> redirect(to: payment_method_path(conn, :show, payment_method))
    else
      conn
      |> put_flash(:error, "No file given")
      |> render("new.html", payment_method: payment_method)
    end
  end

  defp add_payment_method_id(statement_lines, payment_method_id) when is_integer(payment_method_id) do
    Enum.map(statement_lines, fn line ->
      %{ line | payment_method_id: payment_method_id }
    end)
  end

  defp add_payment_method_id({:ok, statement_lines}, payment_method_id) do
    add_payment_method_id(statement_lines, String.to_integer(payment_method_id))
  end
end
