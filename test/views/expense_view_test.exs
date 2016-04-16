defmodule CreditCardChecker.ExpenseViewTest do
  use CreditCardChecker.ConnCase, async: true

  alias CreditCardChecker.ExpenseView
  alias CreditCardChecker.Expense
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.Merchant

  @expense %Expense{id: 123,
    time_of_sale: Ecto.DateTime.cast!("2016-04-16 22:00:00"),
    merchant: %Merchant{name: "Whole Foods"},
    payment_method: %PaymentMethod{name: "Visa"},
    amount_in_cents: 4430}

  test "group_by_month with one expense" do
    expected = [{"April 2016", [@expense]}]
    assert ExpenseView.group_by_month([@expense]) == expected
  end
end
