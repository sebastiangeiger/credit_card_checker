defmodule CreditCardChecker.StatementLineTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.User
  import CreditCardChecker.Factory

  @valid_attrs %{
    address: "some content", amount_in_cents: 42, payee: "some content",
    posted_date: "2010-04-17", payment_method_id: 123
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StatementLine.changeset(%StatementLine{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "inserting a changeset" do
    changeset = StatementLine.changeset(%StatementLine{},
                                        attrs_with_dependent_records)
    {status, _} = Repo.insert(changeset)
    assert status == :ok
  end

  defp attrs_with_dependent_records do
    user = create_user(%{email: "somebody@example.com", password: "secret"})
    %PaymentMethod{id: pm_id} = create_payment_method(%{name: "Visa"},
                                                              user: user)
    %{ @valid_attrs | payment_method_id: pm_id }
  end

  test "unmatched_but_with_possible_expense with statement and matching expense" do
    statement_line = create_statement_line(%{amount_in_cents: -123,
                                             payee: "Merchant #1"})
    user = user_for(statement_line)
    create_expense(%{amount_in_cents: 123,
                     payment_method_id: statement_line.payment_method_id},
                   user: user)
    statement_lines = [user_id: user.id]
                      |> StatementLine.unmatched_but_with_possible_expense()
                      |> Repo.all
    assert statement_lines == [statement_line]
  end

  test "unmatched_but_with_possible_expense with statement but no matching expense" do
    statement_line = create_statement_line(%{amount_in_cents: -123,
                                             payee: "Merchant #1"})
    user = user_for(statement_line)
    create_expense(%{amount_in_cents: 124,
                     payment_method_id: statement_line.payment_method_id},
                   user: user)
    statement_lines = [user_id: user.id]
                      |> StatementLine.unmatched_but_with_possible_expense()
                      |> Repo.all
    assert statement_lines == []
  end

  test "unmatched_but_with_possible_expense with statement and two matching expense" do
    statement_line = create_statement_line(%{amount_in_cents: -123,
                                             payee: "Merchant #1"})
    user = user_for(statement_line)
    for _ <- [1,2] do
      create_expense(%{amount_in_cents: 123,
                       payment_method_id: statement_line.payment_method_id},
                     user: user)
    end
    statement_lines = [user_id: user.id]
                      |> StatementLine.unmatched_but_with_possible_expense()
                      |> Repo.all
    assert statement_lines == [statement_line]
  end

  test "unmatched_but_with_possible_expense with matched statement and expense" do
    statement_line = create_statement_line(%{amount_in_cents: -123,
                                             payee: "Merchant #1"})
    user = user_for(statement_line)
    expense = create_expense(%{amount_in_cents: 123,
                               payment_method_id: statement_line.payment_method_id},
                             user: user)
    create_transaction(statement_line: statement_line, expense: expense)
    statement_lines = [user_id: user.id]
                      |> StatementLine.unmatched_but_with_possible_expense()
                      |> Repo.all
    assert statement_lines == []
  end

  test "unmatched_but_with_possible_expense with statement and otherwise matched expense" do
    statement_line = create_statement_line(%{amount_in_cents: -123,
                                             payee: "Merchant #1"})
    statement_line_2 = create_statement_line(
      %{amount_in_cents: -123, payee: "Merchant #2",
        payment_method_id: statement_line.payment_method_id})
    user = user_for(statement_line)
    expense = create_expense(%{amount_in_cents: 123,
                               payment_method_id: statement_line.payment_method_id},
                             user: user)
    create_transaction(statement_line: statement_line_2, expense: expense)
    statement_lines = [user_id: user.id]
                      |> StatementLine.unmatched_but_with_possible_expense()
                      |> Repo.all
    assert statement_lines == []
  end

  defp user_for(%StatementLine{payment_method_id: payment_method_id}) do
    user_id = Repo.get_by!(PaymentMethod, id: payment_method_id).user_id
    Repo.get_by!(User, id: user_id)
  end
end
