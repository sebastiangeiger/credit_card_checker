defmodule ExpensesPage do
  use PageObject

  visitable :visit, "http://localhost:4001/expenses"

  collection :expenses, item_scope: ".sem-expense" do
    text :merchant_name, "td:nth-child(2)"
    text :payment_method_name, "td:nth-child(3)"
    text :amount, "td:nth-child(4)"
  end

  text :alert, ".alert"

  def number_of_expenses do
    visit
    ExpensesPage.Expenses.all
    |> Enum.count
  end
end


