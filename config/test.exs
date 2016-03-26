use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :credit_card_checker, CreditCardChecker.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :credit_card_checker, CreditCardChecker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "credit_card_checker_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
