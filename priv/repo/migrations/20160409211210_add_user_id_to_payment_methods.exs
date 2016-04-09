defmodule CreditCardChecker.Repo.Migrations.AddUserIdToPaymentMethods do
  use Ecto.Migration

  def change do
    alter table(:payment_methods) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
