defmodule CreditCardChecker.StatementLineExpenseMatcherTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementLineExpenseMatcher
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.TableModel.Line
  alias CreditCardChecker.TableModel.Cell

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

  test "view_model with a statement line and an expense returns the right table model" do
    expense = %Expense{
      amount_in_cents: 123,
      time_of_sale: Ecto.DateTime.cast!("2015-04-20 13:37:00"),
      merchant: %Merchant{name: "Merchant #1"},
      payment_method: @payment_method
    }
    view_model = StatementLineExpenseMatcher.view_model(@statement_line, expense)
    assert view_model == [
      %Line{cells: [%Cell{content: "Amount"},              %Cell{content: "Amount"}]},
      %Line{cells: [%Cell{content: "-1.23"},               %Cell{content: "1.23"}]},
      %Line{cells: [%Cell{content: "Payee"},               %Cell{content: "Payee"}]},
      %Line{cells: [%Cell{content: "MERCHANT #1"},         %Cell{content: "Merchant #1"}]},
      %Line{cells: [%Cell{content: "Date"},                %Cell{content: "Date"}]},
      %Line{cells: [%Cell{content: "2015-04-20"},          %Cell{content: "2015-04-20 13:37:00"}]},
      %Line{cells: [%Cell{content: "Address"},             %Cell{content: "Address"}]},
      %Line{cells: [%Cell{content: "Address #1"},          %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Reference Number"},    %Cell{content: "Reference Number"}]},
      %Line{cells: [%Cell{content: "Reference Number #1"}, %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Payment Method"},      %Cell{content: "Payment Method"}]},
      %Line{cells: [%Cell{content: "Visa"},                %Cell{content: "Visa"}]}
    ]
  end

  test "view_model with a statement line but no expense returns the right table model" do
    view_model = StatementLineExpenseMatcher.view_model(@statement_line, nil)
    assert view_model == [
      %Line{cells: [%Cell{content: "Amount"},              %Cell{content: "Amount"}]},
      %Line{cells: [%Cell{content: "-1.23"},               %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Payee"},               %Cell{content: "Payee"}]},
      %Line{cells: [%Cell{content: "MERCHANT #1"},         %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Date"},                %Cell{content: "Date"}]},
      %Line{cells: [%Cell{content: "2015-04-20"},          %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Address"},             %Cell{content: "Address"}]},
      %Line{cells: [%Cell{content: "Address #1"},          %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Reference Number"},    %Cell{content: "Reference Number"}]},
      %Line{cells: [%Cell{content: "Reference Number #1"}, %Cell{content: ""}]},
      %Line{cells: [%Cell{content: "Payment Method"},      %Cell{content: "Payment Method"}]},
      %Line{cells: [%Cell{content: "Visa"},                %Cell{content: ""}]}
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
