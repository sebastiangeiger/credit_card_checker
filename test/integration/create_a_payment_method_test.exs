defmodule CreditCardChecker.CreateAPaymentMethodTest do
  use CreditCardChecker.IntegrationCase, async: false

  import CreditCardChecker.AuthTestHelper,
    only: [sign_in_through_app: 0]

  setup do
    sign_in_through_app
    :ok
  end

  test "can create payment methods" do
    assert Enum.count(PaymentMethodsPage.PaymentMethods.all) == 0
    NewPaymentMethodPage.create("Golden Visa")
    assert Enum.count(PaymentMethodsPage.PaymentMethods.all) == 1
  end
end
