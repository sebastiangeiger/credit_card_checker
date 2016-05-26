defmodule CreditCardChecker.UserTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.User
  alias CreditCardChecker.Repo

  @valid_attrs %{email: "somebody@example.com", password: "secret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "can't register the same user twice" do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert!
    {_result, changeset} = User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    assert changeset.errors[:email] == {"has already been taken", []}
  end
end
