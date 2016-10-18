defmodule NewMerchantPage do
  use PageObject

  visitable :visit, "http://localhost:4001/merchants/new"

  fillable :fill_name, "input[id='merchant_name']"

  clickable :submit, "input[value='Submit']"

  def create(name) do
    visit
    fill_name(name)
    submit
  end
end


