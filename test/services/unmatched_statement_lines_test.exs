defmodule CreditCardChecker.UnmatchedStatementLinesTest do
  use CreditCardChecker.ModelCase

  alias CreditCardChecker.UnmatchedStatementLines

  import CreditCardChecker.Factory

  test "view_model with a statement line and matching expense" do
    user = create_user(%{email: "somebody@example.com"})
    merchant = create_merchant(%{name: "Whole Foods"}, user: user)
    pm = create_payment_method(%{name: "Visa"}, user: user)
    sl = create_statement_line(%{amount: -12.33, payee: "Whole Foods"}, payment_method: pm)
    create_expense(%{amount: 12.33}, payment_method: pm, merchant: merchant, user: user)

    assert UnmatchedStatementLines.view_model(user.id) ==
      [unmatched_but_with_possible_expense: [sl]]
  end
end
