defmodule CreditCardChecker.CreateAnExpenseTest do
  use CreditCardChecker.IntegrationCase

  test "can navigate to the root page" do
    navigate_to("/")
    jumbo = find_element(:css, ".jumbotron")
            |> visible_text
    assert jumbo =~ "Welcome to Phoenix"
  end
end
