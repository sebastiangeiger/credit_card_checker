defmodule CreditCardChecker.StatementLineExpenseMatcher do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.NoExpense
  alias CreditCardChecker.TableModel.Line
  alias CreditCardChecker.TableModel.Cell
  import CreditCardChecker.MoneyViewHelpers, only: [in_dollars: 1]

  def diff_view(statement_line_id: id) do
    statement_line = Repo.get(StatementLine, id)
    |> Repo.preload(:payment_method)
    expenses = Repo.all(Expense.potential_matches_for(statement_line: statement_line))
    expense = List.first(expenses) || %NoExpense{}
    [statement_line_id: statement_line.id,
      expense_id: expense.id,
      diff_view: view_model(statement_line, expense)]
  end

  defmodule ViewModel do
    defstruct lines: []

    def cast(statement_line, %NoExpense{} = expense) do
      zip_up(side(statement_line), side(expense))
      |> remove_empty_lines
      |> convert_to_table_model
      |> add_row_spanning_cell
    end

    def cast(statement_line, expense) do
      zip_up(side(statement_line), side(expense))
      |> remove_empty_lines
      |> convert_to_table_model
    end

    defp side(%StatementLine{} = statement_line) do
      [
        "Amount": in_dollars(statement_line.amount_in_cents),
        "Payee": statement_line.payee,
        "Date": Ecto.Date.to_string(statement_line.posted_date),
        "Address": statement_line.address,
        "Reference Number": statement_line.reference_number,
        "Payment Method": statement_line.payment_method.name
      ]
    end

    defp side(%Expense{} = expense) do
      [
        "Amount": in_dollars(expense.amount_in_cents),
        "Payee": expense.merchant.name,
        "Date": Ecto.DateTime.to_string(expense.time_of_sale),
        "Address": "",
        "Reference Number": "",
        "Payment Method": expense.payment_method.name
      ]
    end

    defp side(%NoExpense{}) do
      [
        "Amount": nil,
        "Payee": nil,
        "Date": nil,
        "Address": nil,
        "Reference Number": nil,
        "Payment Method": nil
      ]
    end

    def zip_up(left_side, right_side) do
      Keyword.merge(left_side, right_side,
        fn(_key, value_1, value_2) -> [value_1, value_2] end)
    end

    def add_row_spanning_cell(lines) do
      rowspan = Enum.count(lines)
      row_spanning_cell = %Cell{content: "No matching expenses", rowspan: rowspan, class: "no-matches"}
      List.update_at(lines, 0, fn (%Line{cells: [cell | []]} = line) ->
        %{ line | cells: [cell, row_spanning_cell] }
      end)
    end

    def remove_empty_lines(lines) do
      Enum.reject(lines, fn(line) ->
        case line do
          {_headline, ["",""]}  -> true
          {_headline, ["",nil]} -> true
          {_headline, [nil, ""]} -> true
          {_headline, [nil, nil]} -> true
          {_headline, nil} -> true
          {_headline, ""} -> true
          _ -> false
        end
      end)
    end

    def convert_to_table_model(model) do
      for line <- model do
        case line do
          {headline, [left, nil]} ->
            [
              %Line{cells: [%Cell{content: Atom.to_string(headline)}]},
              %Line{cells: [%Cell{content: left}]}
            ]
          {headline, [left, right]} ->
            [
              %Line{cells: [%Cell{content: Atom.to_string(headline)}, %Cell{content: Atom.to_string(headline)}]},
              %Line{cells: [%Cell{content: left}, %Cell{content: right}]}
            ]
        end
      end
      |> List.flatten
    end
  end

  def view_model(statement_line, expense) do
    ViewModel.cast(statement_line, expense)
  end
end
