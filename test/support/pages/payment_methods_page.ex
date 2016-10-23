defmodule PaymentMethodsPage do
  use PageObject

  visitable :visit, "http://localhost:4001/payment_methods"

  collection :payment_methods, item_scope: ".sem-payment-method" do
    text :name, "td:nth-child(1)"
    clickable :click_upload, "a.btn"
  end
end

