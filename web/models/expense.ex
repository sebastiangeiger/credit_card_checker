defmodule CreditCardChecker.Expense do
  use CreditCardChecker.Web, :model

  schema "expenses" do
    field :time_of_sale, Ecto.DateTime
    field :amount_in_cents, :integer
    field :matched, :boolean, virtual: true, default: false
    belongs_to :merchant, CreditCardChecker.Merchant
    belongs_to :payment_method, CreditCardChecker.PaymentMethod
    belongs_to :user, CreditCardChecker.User
    has_one :transaction, CreditCardChecker.Transaction

    timestamps
  end

  @required_fields ~w(time_of_sale amount_in_cents merchant_id payment_method_id user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    params = convert_amount(params)
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:merchant_id)
    |> foreign_key_constraint(:payment_method_id)
    |> validate_merchant_belongs_to_user
    |> validate_payment_method_belongs_to_user
  end

  def mark_matched(expenses) when is_list(expenses) do
    Enum.map(expenses, &mark_matched/1)
  end

  def mark_matched(expense) do
    if expense.transaction do
      %{ expense | matched: true }
    else
      expense
    end
  end

  defp convert_amount(%{"amount" => nil} = params) do
    params
    |> Map.put("amount_in_cents", nil)
    |> Map.delete("amount")
  end

  defp convert_amount(%{"amount" => amount} = params) do
    {amount, _} = Float.parse(amount)
    amount_in_cents = round(amount * 100)
    params
    |> Map.put("amount_in_cents", amount_in_cents)
    |> Map.delete("amount")
  end

  defp convert_amount(params) do
    params
  end

  defp validate_payment_method_belongs_to_user(changeset) do
    validate_belongs_to_same_user(changeset, :payment_method_id, CreditCardChecker.PaymentMethod)
  end

  defp validate_merchant_belongs_to_user(changeset) do
    validate_belongs_to_same_user(changeset, :merchant_id, CreditCardChecker.Merchant)
  end

  defp validate_belongs_to_same_user(changeset, field, struct_type) do
    %{changes: changes, errors: errors} = changeset

    user_id = Map.get(changes, :user_id)
    model_id = Map.get(changes, field)

    model = if is_nil(model_id) do
      nil
    else
      CreditCardChecker.Repo.get(struct_type, model_id)
    end

    new  = if model && model.user_id == user_id do
      []
    else
      [{field, "does not belong to the current user"}]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  def unmatched do
    from e in CreditCardChecker.Expense,
    left_join: t in assoc(e, :transaction),
    where: is_nil(t.id)
  end

  def potential_matches_for(statement_line: statement_line) do
    from e in unmatched,
    where: e.payment_method_id == ^statement_line.payment_method_id,
    where: e.amount_in_cents == ^(-1 * statement_line.amount_in_cents),
    order_by: [desc: e.time_of_sale],
    preload: [:merchant, :payment_method]
  end
end

defmodule CreditCardChecker.NoExpense do
  defstruct id: nil
end
