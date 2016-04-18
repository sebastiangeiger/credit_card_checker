defmodule CreditCardChecker.ExpenseView do
  use CreditCardChecker.Web, :view

  def in_dollars(amount) when is_integer(amount) do
    "#{Float.to_string(amount / 100, decimals: 2)}"
  end

  def in_dollars(_) do
    ""
  end

  def group_by_month(expenses) do
    expenses
    |> Enum.group_by(&month_and_year/1)
    |> Map.to_list
    |> Enum.sort(&>=/2)
    |> Enum.map(&month_name_with_expenses/1)
    |> Enum.map(&sort_expenses_descending/1)
  end

  defp month_and_year(expense) do
    {{year, month, _}, _} = expense.time_of_sale
                            |> Ecto.DateTime.to_erl
    {year, month}
  end

  defp month_name_with_expenses({{year,month}, expenses}) do
    month_name = {{year, month, 15}, {15, 0, 0}}
                  |> Timex.format!("%B %Y", :strftime)
    {month_name, expenses}
  end

  defp sort_expenses_descending({month_name, expenses}) do
    sorted_expenses = expenses
                      |> Enum.sort_by(&(&1.time_of_sale), &>=/2)
    {month_name, sorted_expenses}
  end

  def short_date_format(date) do
    date
    |> Ecto.DateTime.to_erl
    |> Timex.format!("%-d. (%H:%M)", :strftime)
  end
end
