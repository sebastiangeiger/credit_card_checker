defmodule CreditCardChecker.RequireAuthenticated do
  import Plug.Conn

  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import CreditCardChecker.Router.Helpers, only: [session_path: 2]

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
