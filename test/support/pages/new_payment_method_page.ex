defmodule NewPaymentMethodPage do
  use PageObject

  visitable :visit, "http://localhost:4001/payment_methods/new"

  fillable :fill_name, "input[id='payment_method_name']"

  clickable :submit, "input[value='Submit']"

  def create(name) do
    visit
    fill_name(name)
    submit
  end
end

