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
    create_statement_line %{amount: 3.11, payee: "WHOLE FDS", payment_method: %{name: "Amex"}}
    go_to_unclassified_transactions_page
    assert visible_page_text =~ "WHOLE FDS"
    refute visible_page_text =~ "Whole Foods"
  end

  defp go_to_unclassified_transactions_page do
    navigate_to("/")
    find_element(:link_text, "Transactions")
    |> click
  end
end

