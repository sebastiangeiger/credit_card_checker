defmodule CreditCardChecker.ExpenseController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.Expense

  plug :scrub_params, "expense" when action in [:create, :update]

  def index(conn, _params) do
    expenses = Repo.all(Expense)
    |> Expense.decorate
    render(conn, "index.html", expenses: expenses)
  end

  def new(conn, _params) do
    changeset = Expense.changeset(%Expense{})
    render(conn, "new.html", changeset: changeset, merchants: merchants)
  end

  def create(conn, %{"expense" => expense_params}) do
    changeset = Expense.changeset(%Expense{}, expense_params)

    case Repo.insert(changeset) do
      {:ok, _expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: expense_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, merchants: merchants)
    end
  end

  def show(conn, %{"id" => id}) do
    expense = Repo.get!(Expense, id)
    render(conn, "show.html", expense: expense)
  end

  def edit(conn, %{"id" => id}) do
    expense = Repo.get!(Expense, id)
    changeset = Expense.changeset(expense)
    render(conn, "edit.html", expense: expense, changeset: changeset, merchants: merchants)
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    expense = Repo.get!(Expense, id)
    changeset = Expense.changeset(expense, expense_params)

    case Repo.update(changeset) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: expense_path(conn, :show, expense))
      {:error, changeset} ->
        render(conn, "edit.html", expense: expense, changeset: changeset, merchants: merchants)
    end
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

  defp merchants do
    Repo.all from(m in CreditCardChecker.Merchant, order_by: m.name, select: {m.name, m.id})
  end
end
