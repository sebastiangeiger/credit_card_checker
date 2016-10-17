defmodule PaymentMethodsPage do
  use PageObject

  visitable :visit, "http://localhost:4001/payment_methods"

  collection :payment_methods, item_scope: ".sem-payment-method"
end

