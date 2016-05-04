defmodule CreditCardChecker.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :statement_line_id, references(:statement_lines, on_delete: :nothing), null: false
      add :expense_id, references(:expenses, on_delete: :nothing), null: false

      timestamps
    end
    create index(:transactions, [:statement_line_id])
    create index(:transactions, [:expense_id])

  end
end
