defmodule CreditCardChecker.Transaction do
  use CreditCardChecker.Web, :model

  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense

  schema "transactions" do
    belongs_to :statement_line, StatementLine
    belongs_to :expense, Expense

    timestamps
  end

  @required_fields ~w(expense_id statement_line_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:statement_line_id)
    |> foreign_key_constraint(:expense_id)
    |> unique_constraint(:statement_line_id)
    |> unique_constraint(:expense_id)
    |> validate_amounts_add_up
    |> validate_same_payment_method
  end

  defp validate_amounts_add_up(changeset) do
    validate_against_statement_line_and_expense(changeset,
      fn(changeset, statement_line, expense, errors) ->
        if statement_line.amount_in_cents + expense.amount_in_cents == 0 do
          changeset
        else
          new = [base: "Amounts of StatementLine and Expense don't add up"]
          %{ changeset | errors: new ++ errors, valid?: false }
        end
      end)
  end

  defp validate_same_payment_method(changeset) do
    validate_against_statement_line_and_expense(changeset,
      fn(changeset, statement_line, expense, errors) ->
        if statement_line.payment_method_id == expense.payment_method_id do
          changeset
        else
          new = [base: "StatementLine and Expense need to belong to same PaymentMethod"]
          %{ changeset | errors: new ++ errors, valid?: false }
        end
      end)
  end

  defp validate_against_statement_line_and_expense(changeset, function) do
    %{changes: changes, errors: errors} = changeset
    case changes do
      %{statement_line_id: statement_line_id, expense_id: expense_id} ->
        statement_line = Repo.get(StatementLine, statement_line_id)
        expense = Repo.get(Expense, expense_id)
        function.(changeset, statement_line, expense, errors)
      _ ->
        new = [base: "Could not find StatementLine and Expense"]
        %{ changeset | errors: new ++ errors, valid?: false }
    end
  end
end
