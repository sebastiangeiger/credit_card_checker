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

  @required_fields ~w(time_of_sale amount_in_cents)
  @optional_fields ~w(merchant_id payment_method_id user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params, opts \\ []) do
    params = convert_amount(params)
    model
    |> cast(params, @required_fields, @optional_fields)
    |> add_assocs(opts)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:merchant_id)
    |> foreign_key_constraint(:payment_method_id)
    |> validate_merchant_belongs_to_user
    |> validate_payment_method_belongs_to_user
  end

  defp add_assocs(changeset, opts) do
    if Keyword.has_key?(opts, :merchant) do
      put_assoc(changeset, :merchant, opts[:merchant])
    else
      changeset
    end
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
    %{changes: changes, errors: errors} = changeset

    user_id = Map.get(changes, :user_id)
    model_id = Map.get(changes, :payment_method_id)

    model = if is_nil(model_id) do
      nil
    else
      CreditCardChecker.Repo.get(CreditCardChecker.PaymentMethod, model_id)
    end

    new  = if model && model.user_id == user_id do
      []
    else
      [{:payment_method_id, "does not belong to the current user"}]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  defp validate_merchant_belongs_to_user(changeset) do
    %{changes: changes, errors: errors} = changeset

    user_id = Map.get(changes, :user_id)

    new = cond do
      extract_merchant_user_id(changes) == user_id -> []
      true -> [{:merchant_id, "does not belong to the current user"}]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  defp extract_merchant_user_id(changes) do
    get_in_changes(changes, [:merchant, :data, :user_id]) ||
    get_in_changes(changes, [:merchant, :changes, :user_id]) ||
    load_merchant_from_db(changes)
  end

  defp load_merchant_from_db(changes) do
    merchant_id = Map.get(changes, :merchant_id)
    merchant = if is_nil(merchant_id) do
      nil
    else
      CreditCardChecker.Repo.get(CreditCardChecker.Merchant, merchant_id)
    end
    if merchant do
      merchant.user_id
    else
      nil
    end
  end

  # Somehow Kernel.get_in/2 won't work with a changeset
  defp get_in_changes(nil, _path) do
    nil
  end

  defp get_in_changes(result, []) do
    result
  end

  defp get_in_changes(changeset, [ current | remainder ]) do
    get_in_changes(Map.get(changeset, current), remainder)
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
