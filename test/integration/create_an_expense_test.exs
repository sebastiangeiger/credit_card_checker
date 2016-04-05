defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.MerchantsTestHelper,
    only: [create_merchant: 1]
  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [create_payment_method: 1]

  test "can create an expense" do
    create_merchant("Whole Foods")
    create_payment_method("Amex")
    assert Enum.count(expenses_list) == 0
    create_expense(%{amount: "3.13",
                     merchant: "Whole Foods",
                     payment_method: "Amex"})
    assert Enum.count(expenses_list) == 1
    assert visible_page_text =~ "$3.13"
    assert visible_page_text =~ "Whole Foods"
    assert visible_page_text =~ "Amex"
  end

  test "can see merchants in the new expense form" do
    create_merchant("Starbucks")
    create_merchant("Whole Foods")
    create_merchant("CVS")
    go_to_new_expense_form
    options = find_all_elements(:css, "select#expense_merchant_id option")
    |> Enum.map(&visible_text/1)
    assert options == ["Select merchant...", "CVS", "Starbucks", "Whole Foods"]
  end

  test "can see payment methods in the new expense form" do
    create_payment_method("Personal Visa")
    create_payment_method("Golden Visa")
    create_payment_method("Mastercard")
    go_to_new_expense_form
    options = find_all_elements(:css, "select#expense_payment_method_id option")
    |> Enum.map(&visible_text/1)
    assert options == ["Select payment method...", "Golden Visa", "Mastercard", "Personal Visa"]
  end

  def expenses_list do
    navigate_to("/expenses")
    find_all_elements(:css, ".sem-expenses .sem-expense")
  end

  def go_to_new_expense_form do
    navigate_to("/expenses")
    find_element(:link_text, "New expense")
    |> click
  end

  def create_expense(%{amount: money_amount, merchant: merchant_name,
                       payment_method: payment_method}) do
    go_to_new_expense_form
    select_option("expense_merchant_id", merchant_name)
    select_option("expense_payment_method_id", payment_method)
    find_element(:css, "input#expense_amount")
    |> fill_field(money_amount)
    find_element(:css, "input[value='Submit']")
    |> submit_element
    alert_text = find_element(:css, ".alert")
                  |> visible_text
    assert alert_text =~ "Expense created successfully."
  end

  defp select_option(css_id, value) do
    find_all_elements(:css, "select##{css_id} option")
    |> Enum.filter(&(visible_text(&1) == value))
    |> List.first
    |> click
  end
end

