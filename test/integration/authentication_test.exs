defmodule CreditCardChecker.AuthenticationTest do
  use CreditCardChecker.IntegrationCase

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0, sign_out_through_app: 0]

  test "sign in and sign back out" do
    sign_out_through_app
    navigate_to("/merchants")
    assert visible_page_text =~ "You must be logged in to access that page"
    sign_in_through_app
    navigate_to("/merchants")
    assert visible_page_text =~ "New merchant"
    sign_out_through_app
    navigate_to("/merchants")
    assert visible_page_text =~ "You must be logged in to access that page"
  end
end
