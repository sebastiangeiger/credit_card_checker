defmodule CreditCardChecker.UnmatchedStatementLines do
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Repo

  def view_model(user_id) do
    unmatched_but_with_possible_expense =
      [user_id: user_id]
      |> StatementLine.unmatched_but_with_possible_expense
      |> Repo.all
    unmatched_expenses =
      [user_id: user_id]
      |> StatementLine.unmatched_debit_for_user
      |> Repo.all
    unmatched_without_possible_expense = diff(unmatched_expenses, unmatched_but_with_possible_expense)
    [
      unmatched_but_with_possible_expense: unmatched_but_with_possible_expense,
      unmatched_without_possible_expense: unmatched_without_possible_expense
    ]
  end

  defp diff(unmatched_expenses, unmatched_but_with_possible_expense) do
    MapSet.difference(
      MapSet.new(unmatched_expenses),
      MapSet.new(unmatched_but_with_possible_expense))
    |> MapSet.to_list
  end
end
