defmodule CreditCardChecker.PaymentMethodsTestHelper do
  use Hound.Helpers

  def payment_methods_list do
    navigate_to("/payment_methods")
    find_all_elements(:css, ".sem-payment-methods .sem-payment-method")
  end

  def create_payment_method(name) do
    navigate_to("/payment_methods")
    find_element(:link_text, "New payment method")
    |> click
    find_element(:css, "input#payment_method_name")
    |> fill_field(name)
    find_element(:css, "input[value='Submit']")
    |> submit_element
  end
end
