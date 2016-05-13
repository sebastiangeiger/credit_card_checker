defmodule CreditCardChecker.StatementParser do
  require Logger
  alias CreditCardChecker.StatementParser.Format1

  def parse(file) do
    file
    |> secure_read
    |> Format1.convert
    |> log_errors(file)
  end

  defp log_errors({:error, "No file given"} = result, file) do
    Logger.info("Could not open '#{file}'")
    result
  end

  defp log_errors({:error, "Could not parse file"} = result, file) do
    Logger.info("Could not parse '#{file}'")
    result
  end

  defp log_errors(result, _file) do
    result
  end

  defp secure_read(file) do
    try do
      {:ok, CSVLixir.read(file)}
    rescue
      File.Error ->
        {:error, "No file given"}
    end
  end
end

defmodule CreditCardChecker.StatementParser.Format1 do
  alias CreditCardChecker.StatementLine

  def convert({:ok, contents}) do
    try do
      {:ok, try_to_convert(contents)}
    rescue
      ArgumentError ->
        {:error, "Could not parse file"}
    end
  end

  def convert({:error, _message} = result) do
    result
  end

  defp try_to_convert(contents) do
    contents
    |> Enum.to_list
    |> split_heading_and_body
    |> convert_to_maps
    |> convert_to_statement_lines
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
