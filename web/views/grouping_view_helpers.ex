defmodule CreditCardChecker.GroupingViewHelpers do
  def group_by_month(records, sort_criteria) do
    records
    |> Enum.group_by(&(month_and_year(&1, sort_criteria)))
    |> Map.to_list
    |> Enum.sort(&>=/2)
    |> Enum.map(&month_name_with_expenses/1)
    |> Enum.map(&(sort_expenses_descending(&1, sort_criteria)))
  end

  defp month_and_year(expense, sort_criteria) do
    {{year, month, _}, _} = sort_criteria.(expense)
                            |> Ecto.DateTime.to_erl
    {year, month}
  end

  defp month_name_with_expenses({{year,month}, expenses}) do
    month_name = {{year, month, 15}, {15, 0, 0}}
                  |> Timex.format!("%B %Y", :strftime)
    {month_name, expenses}
  end

  defp sort_expenses_descending({month_name, expenses}, sort_criteria) do
    sorted_expenses = expenses
                      |> Enum.sort_by(&(sort_criteria.(&1)), &>=/2)
    {month_name, sorted_expenses}
  end
end
