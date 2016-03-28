defmodule CreditCardChecker.Repo.Migrations.CreateExpense do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :time_of_sale, :datetime
      add :amount_in_cents, :integer
      add :merchant_id, references(:merchants, on_delete: :nothing)
      add :payment_method_id, references(:payment_methods, on_delete: :nothing)

      timestamps
    end
    create index(:expenses, [:merchant_id])
    create index(:expenses, [:payment_method_id])

  end
end
