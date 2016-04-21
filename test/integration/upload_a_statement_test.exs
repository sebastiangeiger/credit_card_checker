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
    find_element(:css, "input#statement_file")
    |> attach_file("test/fixtures/format_1.csv")
    find_element(:css, "input[value='Upload']")
    |> submit_element
  end

  defp go_to_new_statement_form do
    navigate_to("/payment_methods")
    find_element(:link_text, "Upload Statement")
    |> click
  end

  defp attach_file(element, input) do
    session_id = Hound.current_session_id
    Hound.RequestUtils.make_req(:post, "session/#{session_id}/element/#{element}/value", %{value: ["#{input}"]})
  end
end

