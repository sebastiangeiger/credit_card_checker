defmodule CreditCardChecker.StatementLineExpenseMatcherTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementLineExpenseMatcher
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.PaymentMethod

  test "view_model with a statement line and an expense returns the right datastructure" do
    pm = %PaymentMethod{
      name: "Visa"
    }
    statement_line = %StatementLine{
      amount_in_cents: -123,
      posted_date: Ecto.Date.cast!("2015-04-20"),
      payee: "MERCHANT #1",
      address: "Address #1",
      reference_number: "Reference Number #1",
      payment_method: pm
    }
    expense = %Expense{
      amount_in_cents: 123,
      time_of_sale: Ecto.DateTime.cast!("2015-04-20 13:37:00"),
      merchant: %Merchant{name: "Merchant #1"},
      payment_method: pm
    }
    view_model = StatementLineExpenseMatcher.view_model(statement_line, expense)
    assert view_model == [
      "Amount": ["-1.23", "1.23"],
      "Payee": ["MERCHANT #1", "Merchant #1"],
      "Date": ["2015-04-20", "2015-04-20 13:37:00"],
      "Address": ["Address #1", ""],
      "Reference Number": ["Reference Number #1", ""],
      "Payment Method": ["Visa", "Visa"]
    ]
  end
end

