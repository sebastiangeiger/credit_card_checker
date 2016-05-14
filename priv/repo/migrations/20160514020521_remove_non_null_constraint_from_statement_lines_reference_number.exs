defmodule CreditCardChecker.Repo.Migrations.RemoveNonNullConstraintFromStatementLinesReferenceNumber do
  use Ecto.Migration

  def change do
    alter table(:statement_lines) do
      modify :reference_number, :string, null: true
    end
  end
end
