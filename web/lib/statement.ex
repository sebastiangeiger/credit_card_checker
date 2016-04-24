defmodule CreditCardChecker.Statement do
  require Ecto.Query
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine

  import CreditCardChecker.StatementParser, only: [parse: 1]

  def insert_all({:ok, statement_lines}) do
    insert_all(statement_lines)
  end

  def insert_all({:error, _explanation} = result) do
    result
  end

  def insert_all(statement_lines) when is_list(statement_lines) do
    #TODO: Use Repo.insert_all once ecto 2.0 is stable
    Repo.transaction(fn ->
      for statement_line <- statement_lines do
        case Repo.insert(statement_line) do
          {:ok, _} -> true
          {:error, _} -> Repo.rollback(:insertion_failed)
        end
      end
    end)
  end

  def parse_and_insert(nil, _payment_method_id)  do
    {:error, "No file given"}
  end

  def parse_and_insert(%Plug.Upload{path: path}, payment_method_id)  do
    parse_and_insert(path, payment_method_id)
  end

  def parse_and_insert(file, payment_method_id) when is_integer(payment_method_id) do
    file
    |> parse
    |> add_payment_method_id(payment_method_id)
    |> remove_duplicate_statement_lines
    |> insert_all
  end

  def parse_and_insert(file, payment_method_id) do
    parse_and_insert(file, String.to_integer(payment_method_id))
  end

  defp add_payment_method_id({:ok, statement_lines}, payment_method_id) when is_integer(payment_method_id) do
    lines = Enum.map(statement_lines, fn line ->
      %{ line | payment_method_id: payment_method_id }
    end)
    {:ok, lines}
  end

  defp add_payment_method_id({:error, _explanation} = result, _payment_method_id) do
    result
  end

  defp remove_duplicate_statement_lines({:error, _} = result) do
    result
  end

  defp remove_duplicate_statement_lines({:ok,[]}) do
    {:ok, []}
  end

  defp remove_duplicate_statement_lines({:ok, new_statement_lines}) when is_list(new_statement_lines) do
    %StatementLine{payment_method_id: payment_method_id} = List.first(new_statement_lines)
    existing_statement_lines = Ecto.Query.from(line in StatementLine,
        where: line.payment_method_id == ^payment_method_id)
    |> Repo.all
    lines = Enum.reject(new_statement_lines,
                        &(StatementLine.similar?(&1, existing_statement_lines)))
    {:ok, lines}
  end
end
