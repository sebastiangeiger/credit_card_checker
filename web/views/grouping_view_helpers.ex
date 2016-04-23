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
    {year, month, _} = sort_criteria.(expense)
                       |> to_erlang_date
    {year, month}
  end

  defp to_erlang_date(%Ecto.DateTime{} = date_time) do
    {date, _time} = Ecto.DateTime.to_erl(date_time)
    date
  end

  defp to_erlang_date(%Ecto.Date{} = date) do
    Ecto.Date.to_erl(date)
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
