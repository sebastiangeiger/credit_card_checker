defmodule CreditCardChecker.ExpenseView do
  use CreditCardChecker.Web, :view
  import CreditCardChecker.MoneyViewHelpers
  alias CreditCardChecker.GroupingViewHelpers

  def group_by_month(records) do
    GroupingViewHelpers.group_by_month(records, &(sort_criteria(&1)))
  end

  defp sort_criteria(record) do
    record.time_of_sale
  end

  def short_date_format(date) do
    date
    |> Ecto.DateTime.to_erl
    |> Timex.format!("%-d.", :strftime)
  end
end
