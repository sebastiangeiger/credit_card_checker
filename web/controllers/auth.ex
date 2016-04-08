defmodule CreditCardChecker.Auth do
  import Plug.Conn

  alias CreditCardChecker.User

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user_email = get_session(conn, :user_email)
    user = user_email && %User{email: user_email}
    assign(conn, :current_user, user)
  end
end
