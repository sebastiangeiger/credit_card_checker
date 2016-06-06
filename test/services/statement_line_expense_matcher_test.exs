defmodule CreditCardChecker.StatementLineExpenseMatcherTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementLineExpenseMatcher
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.NoExpense
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

  test "diff_view with a statement line and an expense returns the right table model" do
    expense = %Expense{
      amount_in_cents: 123,
      time_of_sale: Ecto.DateTime.cast!("2015-04-20 13:37:00"),
      merchant: %Merchant{name: "Merchant #1"},
      payment_method: @payment_method
    }
    diff_view = StatementLineExpenseMatcher.diff_view(@statement_line, expense, false)
    assert diff_view.table == [
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
    assert diff_view.template == "diff.html"
  end

  test "diff_view with a statement line but no expense returns a left panel only" do
    diff_view = StatementLineExpenseMatcher.diff_view(@statement_line, %NoExpense{}, false)
    assert diff_view.left_panel == [
      "Amount": "-1.23",
      "Payee": "MERCHANT #1",
      "Date": "2015-04-20",
      "Address": "Address #1",
      "Reference Number": "Reference Number #1",
      "Payment Method": "Visa"
    ]
    assert diff_view.rowspan == 12
    assert diff_view.template == "diff_right_panel_empty.html"
  end
end

defmodule CreditCardChecker.StatementLineExpenseMatcher.DataAccessTest do
  use ExUnit.Case

  alias CreditCardChecker.Expense
  import CreditCardChecker.StatementLineExpenseMatcher.DataAccess

  @expense_1 %Expense{id: 1}
  @expense_2 %Expense{id: 2}
  @expense_3 %Expense{id: 3}

  test "select_displayed_expense without a expense_id" do
    expenses = [@expense_1, @expense_2, @expense_3]
    actual = select_displayed_expense(expenses, nil)
    expected = {@expense_1, [@expense_2, @expense_3]}
    assert actual == expected
  end

  test "select_displayed_expense with an expense_id" do
    expenses = [@expense_1, @expense_2, @expense_3]
    actual = select_displayed_expense(expenses, 2)
    expected = {@expense_2, [@expense_1, @expense_3]}
    assert actual == expected
  end

  test "select_displayed_expense with an expense_id not in the list" do
    expenses = [@expense_1, @expense_2, @expense_3]
    actual = select_displayed_expense(expenses, 4)
    expected = {@expense_1, [@expense_2, @expense_3]}
    assert actual == expected
  end
end

defmodule CreditCardChecker.StatementLineExpenseMatcher.MatchingExpenseViewModelTest do
  use ExUnit.Case

  import CreditCardChecker.StatementLineExpenseMatcher.MatchingExpenseViewModel

  test "zip_up with two keyword lists" do
    assert zip_up([a: 1, b: 2], [a: 3, b: 4]) == [a: [1, 3], b: [2, 4]]
  end

  test "remove_empty_lines with no empty line" do
    assert remove_empty_lines([a: [1, 3], b: [2, 4]]) == [a: [1, 3], b: [2, 4]]
  end

  test "remove_empty_lines with empty line" do
    assert remove_empty_lines([a: [1, 3], b: ["", ""]]) == [a: [1, 3]]
  end
end

defmodule CreditCardChecker.StatementLineExpenseMatcher.NoMatchingExpenseViewModelTest do
  use ExUnit.Case

  import CreditCardChecker.StatementLineExpenseMatcher.NoMatchingExpenseViewModel

  test "remove_empty_lines with no empty line" do
    assert remove_empty_lines([a: 1, b: 2]) == [a: 1, b: 2]
  end

  test "remove_empty_lines with empty line" do
    assert remove_empty_lines([a: 1, b: ""]) == [a: 1]
  end
end
