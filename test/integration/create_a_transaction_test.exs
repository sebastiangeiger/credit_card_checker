defmodule CreditCardChecker.CreateATransactionTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create a transaction for a statement line and a matching expense" do
    NewExpensePage.create %{amount: 3.11, merchant: %{name: "Whole Foods"},
                                   payment_method: %{name: "Amex"}}
    NewStatementsPage.create %{amount: -3.11, payee: "WHOLE FDS",
                                   payment_method: %{name: "Amex"}}
    go_to_unclassified_transactions_page
    assert visible_page_text =~ "WHOLE FDS"
    refute visible_page_text =~ "Whole Foods"
    find_element(:link_text, "Match")
    |> click
    assert visible_page_text =~ "Whole Foods"
    assert visible_page_text =~ "WHOLE FDS"
    find_element(:css, "input[value='Create']")
    |> submit_element
    go_to_unclassified_transactions_page
    refute visible_page_text =~ "WHOLE FDS"
    refute visible_page_text =~ "Whole Foods"
  end

  test "can select from multiple matching expenses" do
    NewExpensePage.create %{amount: 3.11, merchant: %{name: "Whole Foods"},
                                   payment_method: %{name: "Amex"}}
    NewExpensePage.create %{amount: 3.11, merchant: %{name: "Walgreens"},
                                   payment_method: %{name: "Amex"}}
    NewStatementsPage.create %{amount: -3.11, payee: "WHOLE FDS", payment_method: %{name: "Amex"}}
    go_to_unclassified_transactions_page
    find_element(:link_text, "Match")
    |> click
    diff_table_text = find_element(:css, "table.diff-table")
                      |> visible_text
    assert diff_table_text =~ "Whole Foods"
    assert diff_table_text =~ "WHOLE FDS"
    other_matches_text = find_element(:css, ".sem-other-matches")
                      |> visible_text
    assert other_matches_text =~ "Walgreens"
    find_element(:link_text, "Match")
    |> click
    diff_table_text = find_element(:css, "table.diff-table")
                      |> visible_text
    assert diff_table_text =~ "WHOLE FDS"
    assert diff_table_text =~ "Walgreens"
    other_matches_text = find_element(:css, ".sem-other-matches")
                      |> visible_text
    assert other_matches_text =~ "Whole Foods"
  end

  test "can create a transaction for a statement line without a matching expense" do
    NewPaymentMethodPage.create("Amex")
    NewStatementsPage.create %{amount: -3.11, payee: "WHOLE FDS", payment_method: %{name: "Amex"}}
    go_to_unclassified_transactions_page
    find_element(:link_text, "Match")
    |> click
    assert visible_page_text =~ "No matching expenses"
    find_element(:link_text, "Create expense")
    |> click
    find_element(:css, "input#transaction_merchant_name")
    |> fill_field("Whole Foods")
    find_element(:css, "input[value='Create']")
    |> submit_element
    go_to_unclassified_transactions_page
    refute visible_page_text =~ "WHOLE FDS"
  end

  defp go_to_unclassified_transactions_page do
    navigate_to("/")
    find_element(:link_text, "Transactions")
    |> click
  end
end

