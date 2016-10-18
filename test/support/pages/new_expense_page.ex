defmodule NewExpensePage do
  use PageObject

  visitable :visit, "http://localhost:4001/expenses/new"

  fillable :fill_merchant_name, "input[id='expense_merchant_name']"
  fillable :fill_amount, "input[id='expense_amount']"

  clickable :submit_and_new, "input[value='Submit & New']"
  clickable :submit, "input[value='Submit']"

  def create(%{amount: amount, merchant: %{name: merchant_name},
      payment_method: %{name: payment_method_name}}) do
    NewMerchantPage.create(merchant_name)
    NewPaymentMethodPage.create(payment_method_name)
    visit
    fill_merchant_name(merchant_name)
    fill_amount(amount)
    select_option("expense_payment_method_id", payment_method_name)
    submit
  end

  defp select_option(css_id, value) do
    find_all_elements(:css, "select##{css_id} option")
    |> Enum.filter(&(visible_text(&1) == value))
    |> List.first
    |> click
  end
end


