defmodule CreditCardChecker.UploadAStatementTest do
  use CreditCardChecker.IntegrationCase

  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [create_payment_method: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can upload a statement" do
    create_payment_method("Amex")
    go_to_new_statement_form

  end

  defp go_to_new_statement_form do
    navigate_to("/payment_methods")
    find_element(:link_text, "Upload Statement")
    |> click
  end
end

