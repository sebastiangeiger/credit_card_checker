defmodule CreditCardChecker.LetsencryptchallengeController do
  use CreditCardChecker.Web, :controller
  alias CreditCardChecker.Letsencryptchallenge

  def new(conn, _params) do
    changeset = Letsencryptchallenge.changeset(%Letsencryptchallenge{}, %{})
    conn
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{ "letsencryptchallenge" => challenge_params }) do
    Letsencryptchallenge.changeset(%Letsencryptchallenge{}, challenge_params)
    |> Repo.insert
    conn
    |> redirect(to: expense_path(conn, :index))
  end

  def show(conn, %{"challenge" => challenge}) do
    query = from c in Letsencryptchallenge, where: c.challenge == ^challenge
    case Repo.one(query) do
      nil ->
        conn
        |> put_status(404)
        |> text("")
      challenge -> text conn, challenge.response
    end
  end
end
