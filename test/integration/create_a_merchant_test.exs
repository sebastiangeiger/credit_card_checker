defmodule CreditCardChecker.CreateAMerchantTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.MerchantsTestHelper,
    only: [merchants_list: 0, create_merchant: 1]

  test "can create merchants" do
    assert Enum.count(merchants_list) == 0
    create_merchant("Whole Foods")
    assert Enum.count(merchants_list) == 1
    assert visible_page_text =~ "Whole Foods"
  end
end
