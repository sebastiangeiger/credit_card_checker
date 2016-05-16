defmodule CreditCardChecker.StatementParser do
  require Logger
  alias CreditCardChecker.StatementParser.FormatFinder
  alias CreditCardChecker.StatementParser.ErrorHandler
  alias CreditCardChecker.StatementParser.ParserSkeleton

  @formats [Format1, Format2]

  def parse(file) do
    file
    |> read_lines
    |> find_format_and_convert
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

  defp find_format_and_convert(content) do
    format = FormatFinder.determine_format(content)
    ParserSkeleton.convert(content, format: format)
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

defmodule CreditCardChecker.StatementParser.FormatFinder do
  alias CreditCardChecker.StatementParser.Format1
  alias CreditCardChecker.StatementParser.Format2
  alias CreditCardChecker.StatementParser.Format3
  alias CreditCardChecker.StatementParser.UnknownFormat

  @formats [Format1, Format2, Format3]

  def determine_format(content) do
    case matching_formats(content) do
      [format | []] -> format
      [] -> UnknownFormat
      _ -> raise "Multiple formats matched, this should not happen!"
    end
  end

  defp matching_formats(content) do
    Enum.filter(@formats, fn(format) ->
      understands?(content, format: format)
    end)
  end

  defp understands?({:ok, lines}, format: format) do
    apply(format, :understands?, [lines])
  end

  defp understands?(_, format: _format) do
    false
  end
end

defmodule CreditCardChecker.StatementParser.ParserSkeleton do
  def convert({:ok, _lines} = content, format: format) do
    try do
      apply(format, :convert, [content])
    rescue
      ArgumentError ->
        {:error, "Could not parse file"}
    end
  end

  def convert({:error, _message} = result, format: _) do
    result
  end
end

defmodule CreditCardChecker.StatementParser.FormatHelper do
  def split_heading_and_body([head | body]) do
    %{head: head, body: body}
  end

  def convert_to_maps(%{head: head, body: body}) do
    Enum.map(body, fn line ->
                     Enum.zip(head, line)
                     |> Enum.into(%{})
                   end)
  end

  def mm_dd_yyyy_to_date(date_string) do
    [_, m, d, y] = Regex.run(~r{(\d+)/(\d+)/(\d+)}, date_string)
    Ecto.Date.cast!({y,m,d})
  end

  def ok_response(lines) do
    {:ok, lines}
  end
end

defmodule CreditCardChecker.StatementParser.UnknownFormat do
  def convert({:ok, _}) do
    {:error, "Could not recognize the file format"}
  end
end

defmodule CreditCardChecker.StatementParser.Format1 do
  alias CreditCardChecker.StatementLine
  import CreditCardChecker.StatementParser.FormatHelper

  def understands?([head | _rest]) do
    head == ["Posted Date", "Reference Number", "Payee", "Address", "Amount"]
  end

  def convert({:ok, lines}) do
    lines
    |> split_heading_and_body
    |> convert_to_maps
    |> convert_to_statement_lines
    |> ok_response
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
end

defmodule CreditCardChecker.StatementParser.Format2 do
  alias CreditCardChecker.StatementLine
  import CreditCardChecker.StatementParser.FormatHelper

  def understands?([head | _rest]) do
    head == ["Status","Date","Description","Debit","Credit"]
  end

  def convert({:ok, lines}) do
    lines
    |> split_heading_and_body
    |> convert_to_maps
    |> only_cleared_lines
    |> convert_to_statement_lines
    |> ok_response
  end

  defp only_cleared_lines(lines) do
    Enum.filter(lines, &(&1["Status"] == "Cleared"))
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

  defp amount_in_cents(%{"Credit" => credit, "Debit" => debit}) do
    {amount, sign} = case [credit, debit] do
      ["",""] -> {"0.0", 1}
      ["", debit] ->  {debit, -1}
      [credit, ""] -> {credit, +1}
    end
    round(String.to_float(amount) * 100 * sign)
  end

  defp split_up_description(description) do
    if String.slice(description, 22, 1) == " " do
      {payee, address} = String.split_at(description, 22)
      {String.strip(payee), String.strip(address)}
    else
      {description, nil}
    end
  end

  defp convert_to_statement_lines(maps) do
    Enum.map(maps, &convert_to_statement_line/1)
  end
end

defmodule CreditCardChecker.StatementParser.Format3 do
  alias CreditCardChecker.StatementLine
  import CreditCardChecker.StatementParser.FormatHelper

  def understands?([head | _rest]) do
    head == ["Type","Trans Date","Post Date","Description","Amount"]
  end

  def convert({:ok, lines}) do
    lines
    |> split_heading_and_body
    |> convert_to_maps
    |> convert_to_statement_lines
    |> ok_response
  end

  defp convert_to_statement_line(map) do
    %StatementLine{
      address: nil,
      amount_in_cents: round(String.to_float(map["Amount"]) * 100),
      payee: map["Description"],
      reference_number: nil,
      posted_date: mm_dd_yyyy_to_date(map["Trans Date"])
    }
  end

  defp convert_to_statement_lines(maps) do
    Enum.map(maps, &convert_to_statement_line/1)
  end
end
