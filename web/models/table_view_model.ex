defmodule CreditCardChecker.TableModel do
  defmodule Line do
    defstruct cells: []
  end

  defmodule Cell do
    defstruct content: "", rowspan: 1, class: ""
  end
end
