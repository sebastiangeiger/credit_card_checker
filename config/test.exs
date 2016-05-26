use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :credit_card_checker, CreditCardChecker.Endpoint,
  http: [port: 4001],
  server: true

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


config :hound, driver: "phantomjs"

config :credit_card_checker, sql_sandbox: true


config :comeonin, :bcrypt_log_rounds, 1
config :comeonin, :pbkdf2_rounds, 1
