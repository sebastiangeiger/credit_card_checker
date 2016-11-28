defmodule CreditCardChecker.Repo.Migrations.CreateLetsencryptchallenges do
  use Ecto.Migration

  def change do
    create table(:letsencryptchallenges) do
      add :challenge, :text
      add :response, :text
    end
    create index(:letsencryptchallenges, [:challenge])
  end
end
