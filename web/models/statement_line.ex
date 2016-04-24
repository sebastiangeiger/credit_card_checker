defmodule CreditCardChecker.StatementLine do
  use CreditCardChecker.Web, :model
  alias CreditCardChecker.StatementLine

  schema "statement_lines" do
    field :amount_in_cents, :integer
    field :posted_date, Ecto.Date
    field :reference_number, :string
    field :address, :string
    field :payee, :string
    belongs_to :payment_method, CreditCardChecker.PaymentMethod

    timestamps
  end

  @required_fields ~w(amount_in_cents posted_date reference_number payee payment_method_id)
  @optional_fields ~w(address)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:payment_method_id)
  end

  def similar?(%StatementLine{} = a, %StatementLine{} = b) do
    a.posted_date == b.posted_date &&
      a.payee == b.payee &&
      a.amount_in_cents == b.amount_in_cents
  end

  def similar?(%StatementLine{} = a, list) when is_list(list) do
    Enum.any?(list, &(similar?(&1, a)))
  end

  def similar?(_, _) do
    false
  end

end
