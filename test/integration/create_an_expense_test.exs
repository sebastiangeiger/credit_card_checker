defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.MerchantsTestHelper,
    only: [create_merchant: 1]

  test "can create an expense" do
    create_merchant("Whole Foods")
    assert Enum.count(expenses_list) == 0
    create_expense(%{amount: "3.13", merchant: "Whole Foods"})
    assert Enum.count(expenses_list) == 1
    assert visible_page_text =~ "$3.13"
    assert visible_page_text =~ "Whole Foods"
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

  def expenses_list do
    navigate_to("/expenses")
    find_all_elements(:css, ".sem-expenses .sem-expense")
  end

  def go_to_new_expense_form do
    navigate_to("/expenses")
    find_element(:link_text, "New expense")
    |> click
  end

  def create_expense(%{amount: money_amount, merchant: merchant_name}) do
    go_to_new_expense_form
    find_all_elements(:css, "select#expense_merchant_id option")
    |> Enum.filter(&(visible_text(&1) == merchant_name))
    |> List.first
    |> click
    find_element(:css, "input#expense_amount")
    |> fill_field(money_amount)
    find_element(:css, "input[value='Submit']")
    |> submit_element
    alert_text = find_element(:css, ".alert")
                  |> visible_text
    assert alert_text =~ "Expense created successfully."
  end
end

