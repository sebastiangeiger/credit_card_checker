defmodule CreditCardChecker.Repo.Migrations.CreateStatementLine do
  use Ecto.Migration

  def change do
    create table(:statement_lines) do
      add :amount_in_cents, :integer, null: false
      add :posted_date, :date, null: false
      add :reference_number, :string, null: false
      add :address, :string
      add :payee, :string, null: false
      add :payment_method_id, references(:payment_methods, on_delete: :nothing), null: false

      timestamps
    end
    create index(:statement_lines, [:payment_method_id])

  end
end
