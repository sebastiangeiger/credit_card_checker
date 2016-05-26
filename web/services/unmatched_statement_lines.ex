defmodule CreditCardChecker.UnmatchedStatementLines do
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Repo

  def view_model(user_id) do
    unmatched_but_with_possible_expense =
      [user_id: user_id]
      |> StatementLine.unmatched_but_with_possible_expense
      |> Repo.all

    [unmatched_but_with_possible_expense: unmatched_but_with_possible_expense]
  end
end
