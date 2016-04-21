defmodule CreditCardChecker.Statement do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine

  def insert_all(statement_lines) do
    #TODO: Use Repo.insert_all once ecto 2.0 is stable
    Repo.transaction(fn ->
      for statement_line <- statement_lines do
        Repo.insert!(statement_line)
      end
    end)
  end
end
