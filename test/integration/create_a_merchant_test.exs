defmodule CreditCardChecker.CreateAMerchantTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create merchants" do
    assert Enum.count(MerchantsPage.Merchants.all) == 0
    NewMerchantPage.create("Whole Foods")
    assert Enum.count(MerchantsPage.Merchants.all) == 1
    assert visible_page_text =~ "Whole Foods"
  end
end
