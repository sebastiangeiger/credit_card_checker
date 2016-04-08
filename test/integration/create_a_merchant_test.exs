defmodule CreditCardChecker.CreateAMerchantTest do
  use CreditCardChecker.IntegrationCase

  import CreditCardChecker.MerchantsTestHelper,
    only: [merchants_list: 0, create_merchant: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create merchants" do
    assert Enum.count(merchants_list) == 0
    create_merchant("Whole Foods")
    assert Enum.count(merchants_list) == 1
    assert visible_page_text =~ "Whole Foods"
  end
end
