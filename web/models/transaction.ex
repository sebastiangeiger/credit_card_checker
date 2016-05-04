defmodule CreditCardChecker.Transaction do
  use CreditCardChecker.Web, :model

  schema "transactions" do
    belongs_to :statement_line, CreditCardChecker.StatementLine
    belongs_to :expense, CreditCardChecker.Expense

    timestamps
  end

  @required_fields ~w(expense_id statement_line_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:statement_line_id)
    |> foreign_key_constraint(:expense_id)
    |> unique_constraint(:statement_line_id)
    |> unique_constraint(:expense_id)
  end
end
