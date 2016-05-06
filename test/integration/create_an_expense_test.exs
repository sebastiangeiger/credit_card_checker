defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [create_payment_method: 1]
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
    create_payment_method("Personal Visa")
    create_payment_method("Golden Visa")
    create_payment_method("Mastercard")
    go_to_new_expense_form
    options = find_all_elements(:css, "select#expense_payment_method_id option")
    |> Enum.map(&visible_text/1)
    assert options == ["Select payment method...", "Golden Visa", "Mastercard", "Personal Visa"]
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

