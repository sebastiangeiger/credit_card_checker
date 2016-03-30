defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase

  test "can create an expense" do
    assert Enum.count(expenses_list) == 0
    create_expense("3.00")
    assert Enum.count(expenses_list) == 1
    assert visible_page_text =~ "$3.0"
  end

  def expenses_list do
    navigate_to("/expenses")
    find_all_elements(:css, ".sem-expenses .sem-expense")
  end

  def create_expense(money_amount) do
    navigate_to("/expenses")
    find_element(:link_text, "New expense")
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

