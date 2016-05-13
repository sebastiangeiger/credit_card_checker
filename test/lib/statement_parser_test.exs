defmodule CreditCardChecker.StatementParserTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementParser
  alias CreditCardChecker.StatementLine

  test "reading the csv file of Format1 generates the correct StatementLines" do
    {:ok, lines} = StatementParser.parse("test/fixtures/format_1.csv")
    assert Enum.count(lines) == 4
    line = %StatementLine{
      amount_in_cents: -870,
      address: "ADDRESS #1",
      payee: "PAYEE #1",
      reference_number: "24492156019719803515390",
      posted_date: Ecto.Date.cast!({2013, 4, 21})
    }
    assert List.first(lines) == line
  end

  test "reading the csv file of Format2 generates the correct StatementLines" do
    {:ok, lines} = StatementParser.parse("test/fixtures/format_2.csv")
    assert Enum.count(lines) == 5
    line = %StatementLine{
      amount_in_cents: -2000,
      address: "Address #1",
      payee: "Merchant #1",
      reference_number: nil,
      posted_date: Ecto.Date.cast!({2016, 5, 11})
    }
    assert List.first(lines) == line
  end

  test "reading an invalid csv file" do
    path = "test/fixtures/not_a_valid_csv.csv"
    assert File.exists?(path)
    {:error, "Could not parse file"} = StatementParser.parse(path)
  end

  test "reading a file that does not exist" do
    path = "test/fixtures/i_dont_exist.csv"
    refute File.exists?(path)
    {:error, "No file given"} = StatementParser.parse(path)
  end

  test "reading a csv file that has an unknown format" do
    path = "test/fixtures/unknown_format.csv"
    assert File.exists?(path)
    {:error, "Could not recognize the file format"} = StatementParser.parse(path)
  end
end
