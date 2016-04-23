defmodule CreditCardChecker.Statement do
  alias CreditCardChecker.Repo
  alias CreditCardChecker.StatementLine

  def insert_all(statement_lines) do
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

  def parse_file(statement_file) do
    CreditCardChecker.StatementParser.parse(statement_file)
  end

  def parse_and_insert(nil, _payment_method_id)  do
    {:error, "No file given"}
  end

  def parse_and_insert(%Plug.Upload{path: path}, payment_method_id)  do
    parse_and_insert(path, payment_method_id)
  end

  def parse_and_insert(file, payment_method_id) when is_integer(payment_method_id) do
    file
    |> parse_file
    |> add_payment_method_id(payment_method_id)
    |> insert_all
  end

  def parse_and_insert(file, payment_method_id) do
    parse_and_insert(file, String.to_integer(payment_method_id))
  end

  defp add_payment_method_id({:ok, statement_lines}, payment_method_id) when is_integer(payment_method_id) do
    Enum.map(statement_lines, fn line ->
      %{ line | payment_method_id: payment_method_id }
    end)
  end
end
