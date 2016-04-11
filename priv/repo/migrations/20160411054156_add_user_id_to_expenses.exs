defmodule CreditCardChecker.Repo.Migrations.AddUserIdToExpenses do
  use Ecto.Migration

  def change do
    alter table(:expenses) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
