defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase

  test "can create an expense" do
    assert Enum.count(expenses_list) == 0
    create_expense(300)
    assert Enum.count(expenses_list) == 1
  end

  def expenses_list do
    navigate_to("/expenses")
    find_all_elements(:css, ".sem-expenses .sem-expense")
  end

  def create_expense(cents) do
    navigate_to("/expenses")
    find_element(:link_text, "New expense")
    |> click
    find_element(:css, "input#expense_amount_in_cents")
    |> fill_field(cents)
    find_element(:css, "input[value='Submit']")
    |> submit_element
  end
end

