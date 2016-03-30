defmodule CreditCardChecker.ExpenseView do
  use CreditCardChecker.Web, :view

  def in_dollars(amount) when is_integer(amount) do
    "$#{Float.to_string(amount / 100, decimals: 2)}"
  end

  def in_dollars(_) do
    ""
  end
end
