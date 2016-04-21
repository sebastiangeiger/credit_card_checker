defmodule CreditCardChecker.PaymentMethodController do
  use CreditCardChecker.Web, :controller

  plug CreditCardChecker.RequireAuthenticated

  alias CreditCardChecker.PaymentMethod

  plug :scrub_params, "payment_method" when action in [:create, :update]

  def index(conn, _params) do
    payment_methods = Repo.all(from p in PaymentMethod,
                                where: p.user_id == ^conn.assigns.current_user.id)
    render(conn, "index.html", payment_methods: payment_methods)
  end

  def new(conn, _params) do
    changeset = PaymentMethod.changeset(%PaymentMethod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"payment_method" => payment_method_params}) do
    payment_method_params = add_current_user_id(payment_method_params, conn)
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
                      |> Repo.preload([:statement_lines])
    render(conn, "show.html", payment_method: payment_method)
  end
end
