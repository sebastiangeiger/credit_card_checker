defmodule CreditCardChecker.StatementParser do
  alias CreditCardChecker.StatementLine

  def parse(file) do
    result = file
              |> read
              |> split_heading_and_body
              |> convert_to_maps
              |> convert_to_statement_lines
    {:ok, result}
  end

  defp read(file) do
    CSVLixir.read(file)
    |> Enum.to_list
  end

  defp split_heading_and_body([head | body]) do
    %{head: head, body: body}
  end

  defp convert_to_maps(%{head: head, body: body}) do
    Enum.map(body, fn line ->
                     Enum.zip(head, line)
                     |> Enum.into(%{})
                   end)
  end

  defp convert_to_statement_lines(maps) do
    Enum.map(maps, &convert_to_statement_line/1)
  end

  defp convert_to_statement_line(map) do
    %StatementLine{
      address: map["Address"],
      amount_in_cents: round(String.to_float(map["Amount"]) * 100),
      payee: map["Payee"],
      reference_number: map["Reference Number"],
      posted_date: mm_dd_yyyy_to_date(map["Posted Date"])
    }
  end

  defp mm_dd_yyyy_to_date(date_string) do
    [_, m, d, y] = Regex.run(~r{(\d+)/(\d+)/(\d+)}, date_string)
    Ecto.Date.cast!({y,m,d})
  end
end
