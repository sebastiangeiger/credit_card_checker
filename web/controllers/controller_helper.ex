defmodule CreditCardChecker.ControllerHelper do
  def add_current_user_id(params, conn) do
    Map.put_new(params, "user_id", conn.assigns.current_user.id)
  end
end
