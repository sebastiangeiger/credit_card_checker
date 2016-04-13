defmodule CreditCardChecker.Expense do
  use CreditCardChecker.Web, :model

  schema "expenses" do
    field :time_of_sale, Ecto.DateTime
    field :amount_in_cents, :integer
    belongs_to :merchant, CreditCardChecker.Merchant
    belongs_to :payment_method, CreditCardChecker.PaymentMethod
    belongs_to :user, CreditCardChecker.User

    timestamps
  end

  @required_fields ~w(time_of_sale amount_in_cents merchant_id payment_method_id user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = convert_amount(params)
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:merchant_id)
    |> foreign_key_constraint(:payment_method_id)
    |> validate_merchant_belongs_to_user
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

  defp validate_merchant_belongs_to_user(changeset) do
    %{changes: changes, errors: errors} = changeset

    user_id = Map.get(changes, :user_id)
    merchant_id = Map.get(changes, :merchant_id)

    merchant = if is_nil(merchant_id) do
      nil
    else
      CreditCardChecker.Repo.get(CreditCardChecker.Merchant, merchant_id)
    end

    new  = if merchant && merchant.user_id == user_id do
      []
    else
      [merchant_id: "does not belong to the current user"]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end
end
