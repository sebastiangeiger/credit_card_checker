defmodule CreditCardChecker.LetsencryptControllerTest do
  use CreditCardChecker.ConnCase
  alias CreditCardChecker.Letsencryptchallenge

  @valid_attrs %{challenge: "known-challenge", response: "good-response"}
  @invalid_attrs %{}

  test "GET /letsencryptchallenges/new", %{conn: conn} do
    conn = get conn, "/letsencryptchallenges/new"
    assert html_response(conn, 200)
  end

  test "GET /.well-known/acme-challenge/some-unknown-challenge", %{conn: conn} do
    conn = get conn, "/.well-known/acme-challenge/some-unknown-challenge"
    assert text_response(conn, 404)
  end

  test "GET /.well-known/acme-challenge/known-challenge", %{conn: conn} do
    conn = post conn, letsencryptchallenge_path(conn, :create), letsencryptchallenge: @valid_attrs
    conn = get conn, "/.well-known/acme-challenge/known-challenge"
    assert text_response(conn, 200) == "good-response"
  end

  test "POST /letsencryptchallenges", %{conn: conn} do
    assert Repo.all(Letsencryptchallenge) == []
    conn = post conn, letsencryptchallenge_path(conn, :create), letsencryptchallenge: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :index)
    challenges = Repo.all(Letsencryptchallenge)
    assert Enum.count(challenges) == 1
    assert List.first(challenges).response == "good-response"
  end
end
