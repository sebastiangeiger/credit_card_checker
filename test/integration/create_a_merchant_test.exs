defmodule CreditCardChecker.CreateAMerchantTest do
  use CreditCardChecker.IntegrationCase

  test "can create merchants" do
    assert Enum.count(merchants_list) == 0
    create_merchant("Whole Foods")
    assert Enum.count(merchants_list) == 1
    assert visible_page_text =~ "Whole Foods"
  end

  defp merchants_list do
    navigate_to("/merchants")
    find_all_elements(:css, ".sem-merchants .sem-merchant")
  end

  defp create_merchant(name) do
    navigate_to("/merchants")
    find_element(:link_text, "New merchant")
    |> click
    find_element(:css, "input#merchant_name")
    |> fill_field(name)
    find_element(:css, "input[value='Submit']")
    |> submit_element
    alert_text = find_element(:css, ".alert")
                  |> visible_text
    assert alert_text =~ "Merchant created successfully"
  end
end
