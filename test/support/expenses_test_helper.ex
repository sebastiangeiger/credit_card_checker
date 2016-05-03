defmodule CreditCardChecker.ExpensesTestHelper do
  use Hound.Helpers

  import CreditCardChecker.MerchantsTestHelper,
    only: [create_merchant: 1]
  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [create_payment_method: 1]

  def create_expense(%{amount: amount, merchant: %{name: merchant_name},
      payment_method: %{name: payment_method_name}}) do
    create_merchant(merchant_name)
    create_payment_method(payment_method_name)
    navigate_to("/expenses")
    find_element(:link_text, "+ New Expense")
    |> click
    select_option("expense_merchant_id", merchant_name)
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
