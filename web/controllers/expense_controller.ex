defmodule CreditCardChecker.ExpenseController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.Expense
  alias CreditCardChecker.ExpenseForm

  plug :scrub_params, "expense" when action in [:create, :update]
  plug CreditCardChecker.RequireAuthenticated

  def index(conn, _params) do
    expenses = Repo.all from e in Expense,
                where: e.user_id == ^conn.assigns.current_user.id,
                order_by: [desc: e.time_of_sale],
                preload: [:merchant, :payment_method, :transaction]
    expenses =  Expense.mark_matched(expenses)
    render(conn, "index.html", expenses: expenses)
  end

  def new(conn, _params) do
    time_of_sale = convert_time(Timex.DateTime.local)
    changeset = Expense.empty_changeset(%Expense{time_of_sale: time_of_sale})
    conn
    |> assign_merchants_and_payment_methods
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"expense" => expense_params}) do
    case ExpenseForm.insert(expense_params, user: conn.assigns.current_user) do
      {:ok, _expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: expense_path(conn, :index))
      {:error, _changeset} ->
        time_of_sale = convert_time(Timex.DateTime.local)
        changeset = Expense.empty_changeset(%Expense{time_of_sale: time_of_sale})
        conn
        |> assign_merchants_and_payment_methods
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    expense = Repo.get!(Expense, id)
    |> Repo.preload([:merchant, :payment_method])
    render(conn, "show.html", expense: expense)
  end

  def delete(conn, %{"id" => id}) do
    expense = Repo.get!(Expense, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: expense_path(conn, :index))
  end

  defp assign_merchants_and_payment_methods(conn) do
    conn
    |> assign_merchants
    |> assign_payment_methods
  end

  defp assign_merchants(conn) do
    query = from m in CreditCardChecker.Merchant,
      order_by: m.name,
      select: {m.name, m.id}
    assign(conn, :merchants, Repo.all(query))
  end

  defp assign_payment_methods(conn) do
    query = from m in CreditCardChecker.PaymentMethod,
              order_by: m.name,
              select: {m.name, m.id}
    assign(conn, :payment_methods, Repo.all(query))
  end

  defp convert_time(%Timex.DateTime{} = date) do
    date
    |> Timex.Timezone.convert("America/Los_Angeles")
    |> Timex.to_erlang_datetime
  end
end
