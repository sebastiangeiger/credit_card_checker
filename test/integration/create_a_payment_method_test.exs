defmodule CreditCardChecker.CreateAPaymentMethodTest do
  use CreditCardChecker.IntegrationCase
  import CreditCardChecker.PaymentMethodsTestHelper,
    only: [payment_methods_list: 0, create_payment_method: 1]

  test "can create payment methods" do
    assert Enum.count(payment_methods_list) == 0
    create_payment_method("Golden Visa")
    assert Enum.count(payment_methods_list) == 1
  end
end
