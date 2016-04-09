defmodule CreditCardChecker.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password_hash, :string, null: false
      add :email, :string, null: false

      timestamps
    end
    create unique_index(:users, [:email])
  end
end
