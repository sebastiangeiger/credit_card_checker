defmodule CreditCardChecker.PaymentMethodController do
  use CreditCardChecker.Web, :controller

  alias CreditCardChecker.PaymentMethod

  plug :scrub_params, "payment_method" when action in [:create, :update]

  def index(conn, _params) do
    payment_methods = Repo.all(PaymentMethod)
    render(conn, "index.html", payment_methods: payment_methods)
  end

  def new(conn, _params) do
    changeset = PaymentMethod.changeset(%PaymentMethod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"payment_method" => payment_method_params}) do
    changeset = PaymentMethod.changeset(%PaymentMethod{}, payment_method_params)

    case Repo.insert(changeset) do
      {:ok, _payment_method} ->
        conn
        |> put_flash(:info, "Payment method created successfully.")
        |> redirect(to: payment_method_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    payment_method = Repo.get!(PaymentMethod, id)
    render(conn, "show.html", payment_method: payment_method)
  end

  def edit(conn, %{"id" => id}) do
    payment_method = Repo.get!(PaymentMethod, id)
    changeset = PaymentMethod.changeset(payment_method)
    render(conn, "edit.html", payment_method: payment_method, changeset: changeset)
  end

  def update(conn, %{"id" => id, "payment_method" => payment_method_params}) do
    payment_method = Repo.get!(PaymentMethod, id)
    changeset = PaymentMethod.changeset(payment_method, payment_method_params)

    case Repo.update(changeset) do
      {:ok, payment_method} ->
        conn
        |> put_flash(:info, "Payment method updated successfully.")
        |> redirect(to: payment_method_path(conn, :show, payment_method))
      {:error, changeset} ->
        render(conn, "edit.html", payment_method: payment_method, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    payment_method = Repo.get!(PaymentMethod, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(payment_method)

    conn
    |> put_flash(:info, "Payment method deleted successfully.")
    |> redirect(to: payment_method_path(conn, :index))
  end
end
