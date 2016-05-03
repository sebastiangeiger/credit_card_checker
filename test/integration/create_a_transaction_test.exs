defmodule CreditCardChecker.CreateATransactionTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.ExpensesTestHelper,
    only: [create_expense: 1]
  import CreditCardChecker.StatementsTestHelper,
    only: [create_statement_line: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create a transaction" do
    create_expense %{amount: 3.11, merchant: %{name: "Whole Foods"},
                                   payment_method: %{name: "Amex"}}
    navigate_to("/payment_methods")
    find_element(:link_text, "Show")
    |> click
    statement_lines = find_all_elements(:css, ".sem-statement-lines .sem-statement-line")
    assert Enum.count(statement_lines) == 0
    create_statement_line %{amount: 3.11, payee: "WHOLE FDS", payment_method: %{name: "Amex"}}
    navigate_to("/payment_methods")
    find_element(:link_text, "Show")
    |> click
    statement_lines = find_all_elements(:css, ".sem-statement-lines .sem-statement-line")
    assert Enum.count(statement_lines) == 1
  end
end

