defmodule CreditCardChecker.CreateATransactionTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.ExpensesTestHelper,
    only: [create_expense: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create a transaction" do
    expenses = find_all_elements(:css, ".sem-expenses .sem-expense")
    assert Enum.count(expenses) == 0
    create_expense %{amount: 3.11, merchant: %{name: "Whole Foods"},
                                   payment_method: %{name: "Amex"}}
    navigate_to("/expenses")
    expenses = find_all_elements(:css, ".sem-expenses .sem-expense")
    assert Enum.count(expenses) == 1
  end
end

