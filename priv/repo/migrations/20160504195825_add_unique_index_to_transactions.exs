defmodule CreditCardChecker.Repo.Migrations.AddUniqueIndexToTransactions do
  use Ecto.Migration

  def change do
    drop index(:transactions, [:statement_line_id])
    create unique_index(:transactions, [:statement_line_id])

    drop index(:transactions, [:expense_id])
    create unique_index(:transactions, [:expense_id])
  end
end
