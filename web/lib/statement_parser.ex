defmodule CreditCardChecker.StatementParser do
  require Logger
  alias CreditCardChecker.StatementParser.Format1
  alias CreditCardChecker.StatementParser.Format2
  alias CreditCardChecker.StatementParser.UnknownFormat
  alias CreditCardChecker.StatementParser.ErrorHandler

  @formats [Format1, Format2]

  def parse(file) do
    file
    |> read_lines
    |> convert
    |> ErrorHandler.log_errors(file)
  end

  defp read_lines(file) do
    try do
      {:ok, CSVLixir.read(file) |> Enum.to_list}
    rescue
      File.Error ->
        {:error, "No file given"}
    end
  end

  defp convert(lines) do
    determine_format(lines)
    |> apply(:convert, [lines])
  end

  defp determine_format(lines) do
    matching_formats = Enum.filter(@formats, &(apply(&1, :understands?, [lines])))
    case matching_formats do
      [format] -> format
      [] -> UnknownFormat
    end
  end

  defmodule ErrorHandler do
    def log_errors({:error, "No file given"} = result, file) do
      Logger.info("Could not open '#{file}'")
      result
    end

    def log_errors({:error, "Could not parse file"} = result, file) do
      Logger.info("Could not parse '#{file}'")
      result
    end

    def log_errors(result, _file) do
      result
    end
  end
end

defmodule CreditCardChecker.StatementParser.UnknownFormat do
  def convert({:ok, _}) do
    {:error, "Could not recognize the file format"}
  end

  def convert({:error, _message} = result) do
    result
  end
end

defmodule CreditCardChecker.StatementParser.Format1 do
  alias CreditCardChecker.StatementLine

  def understands?({:ok, [head | rest]}) do
    head == ["Posted Date", "Reference Number", "Payee", "Address", "Amount"]
  end

  def understands?(_) do
    false
  end

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

defmodule CreditCardChecker.StatementParser.Format2 do
  alias CreditCardChecker.StatementLine

  def understands?({:ok, [head | rest]}) do
    head == ["Status","Date","Description","Debit","Credit"]
  end

  #Copied
  def understands?(_) do
    false
  end

  def convert({:ok, lines}) do
    result = lines
              |> split_heading_and_body
              |> convert_to_maps
              |> convert_to_statement_lines
    {:ok, result}
  end

  #Copied
  def convert({:error, _message} = result) do
    result
  end

  #Copied
  defp split_heading_and_body([head | body]) do
    %{head: head, body: body}
  end

  defp convert_to_statement_line(map) do
    {payee, address} = split_up_description(map["Description"])
    %StatementLine{
      address: address,
      amount_in_cents:  amount_in_cents(map),
      payee: payee,
      reference_number: nil,
      posted_date: mm_dd_yyyy_to_date(map["Date"])
    }
  end

  def amount_in_cents(%{"Credit" => credit, "Debit" => debit}) do
    {amount, sign} = case [credit, debit] do
      ["",""] -> {"0.0", 1}
      ["", debit] ->  {debit, -1}
      [credit, ""] -> {credit, +1}
    end
    round(String.to_float(amount) * 100 * sign)
  end

  def split_up_description(description) do
    if String.slice(description, 22, 1) == " " do
      {payee, address} = String.split_at(description, 22)
      {String.strip(payee), String.strip(address)}
    else
      {description, nil}
    end
  end

  #Copied
  defp convert_to_maps(%{head: head, body: body}) do
    Enum.map(body, fn line ->
                     Enum.zip(head, line)
                     |> Enum.into(%{})
                   end)
  end

  #Copied
  defp mm_dd_yyyy_to_date(date_string) do
    [_, m, d, y] = Regex.run(~r{(\d+)/(\d+)/(\d+)}, date_string)
    Ecto.Date.cast!({y,m,d})
  end

  #Copied
  defp convert_to_statement_lines(maps) do
    Enum.map(maps, &convert_to_statement_line/1)
  end

end
