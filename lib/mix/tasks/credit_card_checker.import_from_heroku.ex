defmodule Mix.Tasks.CreditCardChecker.ImportFromHeroku do
  require System
  use Mix.Task

  def run(_args) do
    {url, 0} = System.cmd("heroku", ["pg:backups", "public-url"])
    download(url)
    |> import_into_development_database
    |> File.rm
  end

  defp download(url) do
    path = "latest.dump"
    url = String.strip(url)
    HTTPoison.start
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(url)
    :ok = File.write!(path, body)
    path
  end

  defp import_into_development_database(path) do
    options = ~w{--verbose --clean --no-acl --no-owner -h localhost -d credit_card_checker_dev}
    System.cmd("pg_restore", options ++ [path])
    path
  end
end
