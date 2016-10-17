defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.ExpensesTestHelper,
    only: [create_expense: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create an expense" do
    assert Enum.count(expenses_list) == 0
    create_expense(%{amount: 3.13,
      merchant: %{name: "Whole Foods"}, payment_method: %{name: "Amex"}})
    alert_text = find_element(:css, ".alert")
                  |> visible_text
    assert alert_text =~ "Expense created successfully."
    assert Enum.count(expenses_list) == 1
    assert visible_page_text =~ "$3.13"
    assert visible_page_text =~ "Whole Foods"
    assert visible_page_text =~ "Amex"
  end

  test "can see payment methods in the new expense form" do
    NewPaymentMethodPage.create("Personal Visa")
    NewPaymentMethodPage.create("Golden Visa")
    NewPaymentMethodPage.create("Mastercard")
    go_to_new_expense_form
    options = find_all_elements(:css, "select#expense_payment_method_id option")
    |> Enum.map(&visible_text/1)
    assert options == ["Select payment method...", "Golden Visa", "Mastercard", "Personal Visa"]
  end

  @tag failing_on_ci: true
  test "values are not lost when creating invalid expense" do
    NewPaymentMethodPage.create("Mastercard")
    go_to_new_expense_form
    find_element(:css, ".awesomplete input#expense_merchant_name")
    |> fill_field("Whole Foods")
    find_element(:css, "input#expense_amount")
    |> fill_field("345.60")
    find_element(:css, "input[value='Submit']")
    |> submit_element
    assert visible_page_text =~ "Oops, something went wrong! Please check the errors below."
    merchant_name = find_element(:css, ".awesomplete input#expense_merchant_name")
                    |> attribute_value("value")
    assert merchant_name =~ "Whole Foods"
    amount = find_element(:css, "input#expense_amount")
             |> attribute_value("value")
    assert amount =~ "345.60"
  end

  defp expenses_list do
    navigate_to("/expenses")
    find_all_elements(:css, ".sem-expenses .sem-expense")
  end

  defp go_to_new_expense_form do
    navigate_to("/expenses")
    find_element(:link_text, "+ New Expense")
    |> click
  end
end

