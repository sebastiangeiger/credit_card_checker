defmodule CreditCardChecker.StatementLineExpenseMatcherTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementLineExpenseMatcher
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.PaymentMethod

  @payment_method %PaymentMethod{
      name: "Visa"
    }

  @statement_line %StatementLine{
    amount_in_cents: -123,
    posted_date: Ecto.Date.cast!("2015-04-20"),
    payee: "MERCHANT #1",
    address: "Address #1",
    reference_number: "Reference Number #1",
    payment_method: @payment_method
  }

  test "view_model with a statement line and an expense returns the right datastructure" do
    expense = %Expense{
      amount_in_cents: 123,
      time_of_sale: Ecto.DateTime.cast!("2015-04-20 13:37:00"),
      merchant: %Merchant{name: "Merchant #1"},
      payment_method: @payment_method
    }
    view_model = StatementLineExpenseMatcher.view_model(@statement_line, expense)
    assert view_model == [
      "Amount": ["-1.23", "1.23"],
      "Payee": ["MERCHANT #1", "Merchant #1"],
      "Date": ["2015-04-20", "2015-04-20 13:37:00"],
      "Address": ["Address #1", ""],
      "Reference Number": ["Reference Number #1", ""],
      "Payment Method": ["Visa", "Visa"]
    ]
  end

  test "view_model with a statement line but no expense returns the right datastructure" do
    view_model = StatementLineExpenseMatcher.view_model(@statement_line, nil)
    assert view_model == [
      "Amount": ["-1.23", ""],
      "Payee": ["MERCHANT #1", ""],
      "Date": ["2015-04-20", ""],
      "Address": ["Address #1", ""],
      "Reference Number": ["Reference Number #1", ""],
      "Payment Method": ["Visa", ""]
    ]
  end
end

defmodule CreditCardChecker.StatementLineExpenseMatcher.ViewModelTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementLineExpenseMatcher.ViewModel

  test "zip_up with two keyword lists" do
    assert ViewModel.zip_up([a: 1, b: 2], [a: 3, b: 4]) == [a: [1, 3], b: [2, 4]]
  end
end
