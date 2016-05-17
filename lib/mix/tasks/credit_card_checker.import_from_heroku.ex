defmodule Mix.Tasks.CreditCardChecker.ImportFromHeroku do
  require System
  use Mix.Task

  def run(_args) do
    case System.cmd("heroku", ["pg:backups", "public-url"]) do
      {url, 0} ->  download(url)
                   |> import_into_development_database
                   |> File.rm
      _ -> IO.puts("Could not get the heroku pg backup url")
    end
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
