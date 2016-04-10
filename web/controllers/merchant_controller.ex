defmodule CreditCardChecker.MerchantController do
  use CreditCardChecker.Web, :controller


  alias CreditCardChecker.Merchant

  plug CreditCardChecker.RequireAuthenticated
  plug :scrub_params, "merchant" when action in [:create, :update]

  def index(conn, _params) do
    merchants = Repo.all(from m in Merchant,
                         where: m.user_id == ^conn.assigns.current_user.id)
    render(conn, "index.html", merchants: merchants)
  end

  def new(conn, _params) do
    changeset = Merchant.changeset(%Merchant{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"merchant" => merchant_params}) do
    merchant_params = add_current_user_id(merchant_params, conn)
    changeset = Merchant.changeset(%Merchant{}, merchant_params)

    case Repo.insert(changeset) do
      {:ok, _merchant} ->
        conn
        |> put_flash(:info, "Merchant created successfully.")
        |> redirect(to: merchant_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    merchant = Repo.get!(Merchant, id)
    render(conn, "show.html", merchant: merchant)
  end

  def edit(conn, %{"id" => id}) do
    merchant = Repo.get!(Merchant, id)
    changeset = Merchant.changeset(merchant)
    render(conn, "edit.html", merchant: merchant, changeset: changeset)
  end

  def update(conn, %{"id" => id, "merchant" => merchant_params}) do
    merchant = Repo.get!(Merchant, id)
    changeset = Merchant.changeset(merchant, merchant_params)

    case Repo.update(changeset) do
      {:ok, merchant} ->
        conn
        |> put_flash(:info, "Merchant updated successfully.")
        |> redirect(to: merchant_path(conn, :show, merchant))
      {:error, changeset} ->
        render(conn, "edit.html", merchant: merchant, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    merchant = Repo.get!(Merchant, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(merchant)

    conn
    |> put_flash(:info, "Merchant deleted successfully.")
    |> redirect(to: merchant_path(conn, :index))
  end
end
