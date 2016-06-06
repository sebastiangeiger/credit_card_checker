defmodule CreditCardChecker.StatementLineExpenseMatcher do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Expense
  alias CreditCardChecker.NoExpense
  alias CreditCardChecker.TableModel.Line
  alias CreditCardChecker.TableModel.Cell
  import CreditCardChecker.MoneyViewHelpers, only: [in_dollars: 1]

  defmodule DataAccess do
    def load_data(statement_line_id, expense_id) do
      statement_line = Repo.get(StatementLine, statement_line_id)
                        |> Repo.preload(:payment_method)
      {expense, remaining_expenses} =
      Expense.potential_matches_for(statement_line: statement_line)
      |> Repo.all
      |> adjust_expense_list
      |> select_displayed_expense(expense_id)

      %{statement_line: statement_line, expense: expense, remaining_expenses: remaining_expenses}
    end

    def select_displayed_expense(expenses, nil) do
      [expense | remaining_expenses] = expenses
      {expense, remaining_expenses}
    end

    def select_displayed_expense(expenses, expense_id) when is_binary(expense_id) do
      select_displayed_expense(expenses, String.to_integer(expense_id))
    end

    def select_displayed_expense(expenses, expense_id) do
      index = Enum.find_index(expenses, &(&1.id == expense_id))
      if index do
        {Enum.at(expenses, index), List.delete_at(expenses, index)}
      else
        select_displayed_expense(expenses, nil)
      end
    end

    defp adjust_expense_list([]) do
      [%NoExpense{}]
    end

    defp adjust_expense_list([_ | _] = result) do
      result
    end
  end

  defmodule MatchingExpenseViewModel do
    defstruct table: [], statement_line_id: nil, expense_id: nil,
              template: "diff.html"

    def cast(statement_line, expense) do
      %MatchingExpenseViewModel{
        table: table(statement_line, expense),
        statement_line_id: statement_line.id,
        expense_id: expense.id
      }
    end

    defp table(statement_line, %NoExpense{} = expense) do
      zip_up(side(statement_line), side(expense))
      |> remove_empty_lines
      |> convert_to_table_model
      |> add_row_spanning_cell
    end

    defp table(statement_line, expense) do
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

  def view_model(statement_line_id: id) do
    view_model(statement_line_id: id, expense_id: nil)
  end

  def view_model(statement_line_id: statement_line_id, expense_id: expense_id) do
    %{statement_line: statement_line,
      expense: expense,
      remaining_expenses: remaining_expenses}
      = DataAccess.load_data(statement_line_id, expense_id)

    [statement_line_id: statement_line.id,
     remaining_expenses: remaining_expenses,
     diff_view: diff_view(statement_line, expense)]
  end

  def diff_view(statement_line, expense) do
    MatchingExpenseViewModel.cast(statement_line, expense)
  end
end
