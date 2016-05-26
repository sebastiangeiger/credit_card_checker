defmodule CreditCardChecker.Endpoint do
  use Phoenix.Endpoint, otp_app: :credit_card_checker

  socket "/socket", CreditCardChecker.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :credit_card_checker, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_credit_card_checker_key",
    signing_salt: "w5+6kkiz"


  if Application.get_env(:credit_card_checker, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  plug CreditCardChecker.Router
end
