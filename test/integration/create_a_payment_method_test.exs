defmodule CreditCardChecker.CreateAPaymentMethodTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [payment_methods_list: 0, create_payment_method: 1]
  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create payment methods" do
    assert Enum.count(payment_methods_list) == 0
    create_payment_method("Golden Visa")
    assert Enum.count(payment_methods_list) == 1
  end
end
