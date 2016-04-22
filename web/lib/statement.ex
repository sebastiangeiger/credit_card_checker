defmodule CreditCardChecker.Statement do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine

  def insert_all(statement_lines) do
    #TODO: Use Repo.insert_all once ecto 2.0 is stable
    Repo.transaction(fn ->
      for statement_line <- statement_lines do
        case Repo.insert(statement_line) do
          {:ok, _} -> true
          {:error, _} -> Repo.rollback(:insertion_failed)
        end
      end
    end)
  end
end
