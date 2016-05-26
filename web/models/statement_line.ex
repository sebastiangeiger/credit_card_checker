defmodule CreditCardChecker.StatementLine do
  use CreditCardChecker.Web, :model
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.PaymentMethod

  schema "statement_lines" do
    field :amount_in_cents, :integer
    field :posted_date, Ecto.Date
    field :reference_number, :string
    field :address, :string
    field :payee, :string
    field :matched, :boolean, virtual: true, default: false
    belongs_to :payment_method, CreditCardChecker.PaymentMethod
    has_one :transaction, CreditCardChecker.Transaction

    timestamps
  end

  @required_fields ~w(amount_in_cents posted_date payee payment_method_id)
  @optional_fields ~w(address reference_number)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
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

  def mark_matched(statement_lines) when is_list(statement_lines) do
    Enum.map(statement_lines, &mark_matched/1)
  end

  def mark_matched(%PaymentMethod{} = payment_method) do
    %{ payment_method | statement_lines: mark_matched(payment_method.statement_lines) }
  end

  def mark_matched(%StatementLine{} = statement_line) do
    if statement_line.transaction do
      %{ statement_line | matched: true }
    else
      statement_line
    end
  end

  def unmatched do
    from sl in StatementLine,
    left_join: t in assoc(sl, :transaction),
    where: is_nil(t.id)
  end

  def unmatched_but_with_possible_expense(user_id: current_user_id) do
    from sl in unmatched,
    distinct: true,
    join: pm in assoc(sl, :payment_method),
    join: e in assoc(pm, :expenses),
    left_join: t in assoc(e, :transaction),
    where: pm.user_id == ^current_user_id,
    where: sl.amount_in_cents < 0,
    where: fragment("? = (-1 * ?)", sl.amount_in_cents, e.amount_in_cents),
    where: is_nil(t.id)
  end
end
