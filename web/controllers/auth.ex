defmodule CreditCardChecker.Auth do
  import Plug.Conn

  alias CreditCardChecker.User

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user_email = get_session(conn, :user_email)
    if user_email do
      user = CreditCardChecker.Repo.get_by(User, email: user_email)
      if user do
        assign(conn, :current_user, user)
      else
        conn = delete_session(conn, :user_email)
        assign(conn, :current_user, nil)
      end
    else
      assign(conn, :current_user, nil)
    end
  end
end
