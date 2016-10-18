defmodule MerchantsPage do
  use PageObject

  visitable :visit, "http://localhost:4001/merchants"

  collection :merchants, item_scope: ".sem-merchant"
end


