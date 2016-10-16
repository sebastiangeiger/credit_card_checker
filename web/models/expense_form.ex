defmodule CreditCardChecker.ExpenseForm do
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.Repo
  use Ecto.Schema

  schema "virtual" do
    field :time_of_sale, Ecto.DateTime, virtual: true
    field :amount, :string, virtual: true
    field :merchant_name, :string, virtual: true
    field :payment_method_id, :integer, virtual: true
  end

  def insert(params, user: user) do
    {merchant_params, expense_params} = Map.split(params, ["merchant_name"])
    merchant_params = %{name: merchant_params["merchant_name"], user_id: user.id}
    merchant = find_merchant(merchant_params)
    expense_params = Map.put(expense_params, "user_id", user.id)
    Expense.changeset(%Expense{}, expense_params, merchant: merchant)
    |> Repo.insert
    |> translate_errors
    |> translate_values
  end

  defp translate_errors({:error, %Ecto.Changeset{data: %Expense{}} = changeset}) do
    {amount_error, errors} = Keyword.pop(changeset.errors, :amount_in_cents)
    errors = case amount_error do
      nil -> errors
      _ -> Keyword.put_new(errors, :amount, amount_error)
    end
    merchant_errors = add_prefix_to_keys(changeset.changes.merchant.errors, :merchant_)
    {:error, %{ changeset | errors: errors ++ merchant_errors, action: :insert }}
  end

  defp translate_errors({:ok, _} = result), do: result

  defp translate_values({:error, %Ecto.Changeset{data: %Expense{}, changes: changes} = changeset} = result) do
    new_changes = Map.put_new(changes, :merchant_name, changes.merchant.changes[:name])
    {:error, %{ changeset | changes: new_changes }}
  end

  defp translate_values({:ok, _} = result), do: result

  defp find_merchant(merchant_params) do
    get_merchant(merchant_params) || Merchant.changeset(%Merchant{}, merchant_params)
  end

  defp get_merchant(%{name: nil}) do
    nil
  end

  defp get_merchant(merchant_params) do
    Repo.get_by(Merchant, merchant_params)
  end

  def empty_changeset() do
    time_of_sale = convert_time(Timex.DateTime.local)
    Ecto.Changeset.change(%__MODULE__{time_of_sale: time_of_sale}, %{})
  end

  defp convert_time(%Timex.DateTime{} = date) do
    date
    |> Timex.Timezone.convert("America/Los_Angeles")
    |> Timex.to_erlang_datetime
  end

  defp add_prefix_to_keys(list, prefix) do
    Enum.map(list, fn {key, value} ->
      new_key = String.to_atom(Atom.to_string(prefix) <> Atom.to_string(key))
      {new_key, value}
    end)
  end
end
