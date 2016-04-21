defmodule CreditCardChecker.StatementParserTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementParser
  alias CreditCardChecker.StatementLine

  test "reading the csv file generates the correct StatementLines" do
    lines = StatementParser.parse("test/fixtures/format_1.csv")
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
end
