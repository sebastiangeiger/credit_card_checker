defmodule CreditCardChecker.UploadAStatementTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can upload a statement" do
    NewPaymentMethodPage.create("Amex")
    go_to_new_statement_form
    find_element(:css, "input#statement_file")
    |> attach_file("test/fixtures/format_1.csv")
    find_element(:css, "input[value='Upload']")
    |> submit_element
    assert Enum.count(statement_lines) == 4
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

  defp statement_lines do
    find_all_elements(:css, ".sem-statement-lines .sem-statement-line")
  end
end

