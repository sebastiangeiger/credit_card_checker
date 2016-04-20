defmodule CreditCardChecker.StatementParserTest do
  use ExUnit.Case

  alias CreditCardChecker.StatementParser

  test "reading the csv file generates the correct StatementLines" do
    lines = StatementParser.parse("test/fixtures/format_1.csv")
    assert Enum.count(lines) == 4
  end
end
