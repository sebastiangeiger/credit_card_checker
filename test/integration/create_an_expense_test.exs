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
    options = NewExpensePage.PaymentMethods.all
    |> NewExpensePage.PaymentMethods.name
    assert options == ["Select payment method...", "Golden Visa", "Mastercard", "Personal Visa"]
  end

  @tag failing_on_ci: true
  test "values are not lost when creating invalid expense" do
    NewPaymentMethodPage.create("Mastercard")
    NewExpensePage.visit
    NewExpensePage.fill_merchant_name("Whole Foods")
    NewExpensePage.fill_amount("345.60")
    NewExpensePage.submit
    assert NewExpensePage.alert =~ "Oops, something went wrong! Please check the errors below."
    assert NewExpensePage.merchant_name_value =~ "Whole Foods"
    assert NewExpensePage.amount_value =~ "345.60"
  end
end
