defmodule CreditCardChecker.PaymentMethod do
  use CreditCardChecker.Web, :model

  schema "payment_methods" do
    field :name, :string
    belongs_to :user, CreditCardChecker.User
    has_many :statement_lines, CreditCardChecker.StatementLine
    has_many :expenses, CreditCardChecker.Expense

    timestamps
  end

  @required_fields ~w(name user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
  end
end
