defmodule CreditCardChecker.Repo.Migrations.AddUserIdToMerchants do
  use Ecto.Migration

  def change do
    alter table(:merchants) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
