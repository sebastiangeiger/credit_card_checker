defmodule CreditCardChecker.StatementParser do
  def parse(file) do
    file
    |> read
    |> split_heading_and_body
    |> convert_to_statement_lines
  end

  defp read(file) do
    CSVLixir.read(file)
    |> Enum.to_list
  end

  defp split_heading_and_body([head | body]) do
    %{head: head, body: body}
  end

  defp convert_to_statement_lines(%{head: head, body: body}) do
    Enum.map(body, fn line -> convert_to_statement_line(head, line) end)
  end

  defp convert_to_statement_line(head, line) do
    line
  end
end
