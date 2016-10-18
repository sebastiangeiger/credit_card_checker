defmodule CreditCardChecker.ExpensesTestHelper do
  use Hound.Helpers

  def create_expense(%{amount: amount, merchant: %{name: merchant_name},
      payment_method: %{name: payment_method_name}}) do
    NewMerchantPage.create(merchant_name)
    NewPaymentMethodPage.create(payment_method_name)
    navigate_to("/expenses")
    find_element(:link_text, "+ New Expense")
    |> click
    find_element(:css, "input#expense_merchant_name")
    |> fill_field(merchant_name)
    select_option("expense_payment_method_id", payment_method_name)
    find_element(:css, "input#expense_amount")
    |> fill_field(amount)
    find_element(:css, "input[value='Submit']")
    |> submit_element
  end

  defp select_option(css_id, value) do
    find_all_elements(:css, "select##{css_id} option")
    |> Enum.filter(&(visible_text(&1) == value))
    |> List.first
    |> click
  end
end
