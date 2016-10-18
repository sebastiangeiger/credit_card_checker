defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  alias ExpensesPage.Expenses

  setup do
    sign_in_through_app
    :ok
  end

  test "can create an expense" do
    assert ExpensesPage.number_of_expenses == 0
    NewExpensePage.create(%{amount: 3.13,
      merchant: %{name: "Whole Foods"}, payment_method: %{name: "Amex"}})
    assert ExpensesPage.alert =~ "Expense created successfully."
    assert ExpensesPage.number_of_expenses == 1
    expense = Expenses.get(0)
    assert Expenses.merchant_name(expense) =~ "Whole Foods"
    assert Expenses.amount(expense) =~ "$3.13"
    assert Expenses.payment_method_name(expense) =~ "Amex"
  end

  test "can see payment methods in the new expense form" do
    NewPaymentMethodPage.create("Personal Visa")
    NewPaymentMethodPage.create("Golden Visa")
    NewPaymentMethodPage.create("Mastercard")
    NewExpensePage.visit
    options = find_all_elements(:css, "select#expense_payment_method_id option")
    |> Enum.map(&visible_text/1)
    assert options == ["Select payment method...", "Golden Visa", "Mastercard", "Personal Visa"]
  end

  @tag failing_on_ci: true
  test "values are not lost when creating invalid expense" do
    NewPaymentMethodPage.create("Mastercard")
    NewExpensePage.visit
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
end
