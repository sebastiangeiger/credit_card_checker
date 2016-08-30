defmodule CreditCardChecker.AuthenticationTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 1]

  import CreditCardChecker.UserTestHelper,
    only: [register_as: 1]

  @credentials %{email: "somebody@example.com", password: "super_secret"}

  @tag failing_on_ci: true
  test "sign in and sign back out" do
    navigate_to("/merchants")
    assert visible_page_text =~ "You must be logged in to access that page"
    register_as(@credentials)
    sign_in_through_app(@credentials)
    navigate_to("/merchants")
    assert visible_page_text =~ "New merchant"
  end
end
