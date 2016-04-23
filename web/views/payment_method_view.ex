defmodule CreditCardChecker.PaymentMethodView do
  use CreditCardChecker.Web, :view
  import CreditCardChecker.MoneyViewHelpers
  alias CreditCardChecker.GroupingViewHelpers

  def group_by_month(records) do
    GroupingViewHelpers.group_by_month(records, &(&1.posted_date))
  end

  def short_date_format(date) do
    date
    |> Ecto.Date.to_erl
    |> Timex.format!("%-d.", :strftime)
  end
end
