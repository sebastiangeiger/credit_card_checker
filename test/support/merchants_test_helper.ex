defmodule CreditCardChecker.MerchantsTestHelper do
  use Hound.Helpers

  def merchants_list do
    navigate_to("/merchants")
    find_all_elements(:css, ".sem-merchants .sem-merchant")
  end

  def create_merchant(name) do
    navigate_to("/merchants")
    find_element(:link_text, "New merchant")
    |> click
    find_element(:css, "input#merchant_name")
    |> fill_field(name)
    find_element(:css, "input[value='Submit']")
    |> submit_element
  end
end

