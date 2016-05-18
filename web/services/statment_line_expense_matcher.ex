defmodule CreditCardChecker.StatementLineExpenseMatcher do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  import CreditCardChecker.MoneyViewHelpers, only: [in_dollars: 1]

  def diff_view(statement_line_id: id) do
    statement_line = Repo.get(StatementLine, id)
    |> Repo.preload(:payment_method)
    expenses = Repo.all(Expense.potential_matches_for(statement_line: statement_line))
    [statement_line: statement_line, expenses: expenses]
  end

  def view_model(statement_line, expense) do
    ["Amount":
      [in_dollars(statement_line.amount_in_cents),
       in_dollars(expense.amount_in_cents)],
     "Payee": [statement_line.payee, expense.merchant.name],
     "Date":
       [Ecto.Date.to_string(statement_line.posted_date),
        Ecto.DateTime.to_string(expense.time_of_sale)],
      "Address": [statement_line.address, ""],
      "Reference Number": [statement_line.reference_number, ""],
      "Payment Method":
        [statement_line.payment_method.name,
         expense.payment_method.name]
    ]
  end
end
