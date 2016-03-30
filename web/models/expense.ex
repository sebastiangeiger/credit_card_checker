defmodule CreditCardChecker.Expense do
  use CreditCardChecker.Web, :model

  schema "expenses" do
    field :time_of_sale, Ecto.DateTime
    field :amount_in_cents, :integer
    belongs_to :merchant, CreditCardChecker.Merchant
    belongs_to :payment_method, CreditCardChecker.PaymentMethod

    timestamps
  end

  @required_fields ~w(time_of_sale amount_in_cents)
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
end
