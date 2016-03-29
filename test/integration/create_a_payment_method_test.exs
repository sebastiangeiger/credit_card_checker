defmodule CreditCardChecker.CreateAPaymentMethodTest do
  use CreditCardChecker.IntegrationCase

  test "can create payment methods" do
    assert Enum.count(payment_methods_list) == 0
    create_payment_method("Golden Visa")
    assert Enum.count(payment_methods_list) == 1
  end

  defp payment_methods_list do
    navigate_to("/payment_methods")
    find_all_elements(:css, ".sem-payment-methods .sem-payment-method")
  end

  defp create_payment_method(name) do
    navigate_to("/payment_methods")
    find_element(:link_text, "New payment method")
    |> click
    find_element(:css, "input#payment_method_name")
    |> fill_field(name)
    find_element(:css, "input[value='Submit']")
    |> submit_element
    alert_text = find_element(:css, ".alert")
                  |> visible_text
    assert alert_text =~ "Payment method created successfully"
  end
end
