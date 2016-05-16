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
    assert Enum.count(lines) == 4
    line = %StatementLine{
      amount_in_cents: -7347,
      address: "Address #2",
      payee: "Merchant #2",
      reference_number: nil,
      posted_date: Ecto.Date.cast!({2016, 5, 7})
    }
    assert List.first(lines) == line
  end

  test "reading the csv file of Format3 generates the correct StatementLines" do
    {:ok, lines} = StatementParser.parse("test/fixtures/format_3.csv")
    assert Enum.count(lines) == 3
    line = %StatementLine{
      amount_in_cents: -2500,
      address: nil,
      payee: "MERCHANT #1",
      reference_number: nil,
      posted_date: Ecto.Date.cast!({2016, 5, 9})
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

defmodule CreditCardChecker.StatementParser.Format2Test do
  use ExUnit.Case

  alias CreditCardChecker.StatementParser.Format2
  alias CreditCardChecker.StatementLine

  @head ["Status","Date","Description","Debit","Credit"]

  test "can deal with multiple whitespaces in description" do
    line = ["Cleared","04/23/2016","Merchant               9999999999    CA","8.99",""]
    {:ok, statement_lines} = Format2.convert({:ok, [@head, line]})
    [%StatementLine{address: address, payee: payee} | _] = statement_lines
    assert address == "9999999999    CA"
    assert payee == "Merchant"
  end

  test "if there is no address put everyting into payee" do
    line = ["Cleared","05/02/2016","AUTOPAY 999990000054282RAUTOPAY AUTO-PMT","","267.38"]
    {:ok, statement_lines} = Format2.convert({:ok, [@head, line]})
    [%StatementLine{address: address, payee: payee} | _] = statement_lines
    assert address == nil
    assert payee == "AUTOPAY 999990000054282RAUTOPAY AUTO-PMT"
  end
end
