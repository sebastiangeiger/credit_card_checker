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
    #TODO: Values need to be shown properly if creation fails
    Repo.transaction(fn ->
      {merchant_params, expense_params} = Map.split(params, ["merchant_name"])
      %{status: :ok, changeset: nil, merchant: nil}
      |> create_or_find_merchant(merchant_params, user: user)
      |> create_expense(expense_params, user: user)
      |> rollback_if_necessary
    end)
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

  defp create_or_find_merchant(result, merchant_params, user: user) do
    merchant_params = %{name: merchant_params["merchant_name"], user_id: user.id}
    case find_merchant(merchant_params) do
      (%Merchant{} = merchant) -> %{ result | merchant: merchant }
      nil ->
        case create_merchant(merchant_params) do
          {:ok, merchant} ->
            %{ result | merchant: merchant }
          {:error, changeset} ->
            %{ result | status: :error, changeset: translate_changeset(changeset) }
        end
    end
  end

  defp find_merchant(%{name: nil}) do
    nil
  end

  defp find_merchant(merchant_params) do
    Repo.get_by(Merchant, merchant_params)
  end

  defp create_merchant(merchant_params) do
    Merchant.changeset(%Merchant{}, merchant_params)
    |> Repo.insert
  end

  defp create_expense(result, expense_params, user: user) do
    case result do
      %{status: :ok, merchant: merchant} ->
        expense_params = Map.merge(expense_params,
                                   %{"user_id" => user.id, "merchant_id" => merchant.id})
        changeset = Expense.changeset(%Expense{}, expense_params)
        case Repo.insert(changeset) do
          {:ok, _} -> result
          {:error, _} -> %{ result | status: :error, changeset: translate_changeset(changeset) }
        end
      %{status: :error} -> result
    end
  end

  defp translate_changeset(%Ecto.Changeset{data: %Merchant{}} = changeset) do
    {name_error, errors} = Keyword.pop(changeset.errors, :name)
    errors = case name_error do
      nil -> errors
      _ -> Keyword.put_new(errors, :merchant_name, name_error)
    end
    time_of_sale = convert_time(Timex.DateTime.local)
    %{ Ecto.Changeset.change(%__MODULE__{time_of_sale: time_of_sale}, %{}) | errors: errors, action: :insert }
  end

  defp translate_changeset(%Ecto.Changeset{data: %Expense{}} = changeset) do
    {amount_error, errors} = Keyword.pop(changeset.errors, :amount_in_cents)
    errors = case amount_error do
      nil -> errors
      _ -> Keyword.put_new(errors, :amount, amount_error)
    end
    %Ecto.Changeset{ errors: errors, action: :insert }
  end

  defp rollback_if_necessary(%{status: status} = result) do
    case status do
      :ok -> result[:changeset]
      :error ->
        Repo.rollback(result[:changeset])
    end
  end
end
