defmodule CreditCardChecker.StatementsTestHelper do
  use Hound.Helpers

  def create_statement_line(%{amount: amount, payee: payee, payment_method: %{name: payment_method_name}}) do
    file_path = csv_file_for(amount: amount, payee: payee)
    navigate_to("/payment_methods")
    find_element(:link_text, "Upload Statement")
    |> click
    unless String.contains?(visible_page_text, ~s{Upload statement for "#{payment_method_name}"}) do
      raise "Expected to be on upload page for #{payment_method_name}"
    end
    find_element(:css, "input#statement_file")
    |> attach_file(file_path)
    find_element(:css, "input[value='Upload']")
    |> submit_element
    File.rm(file_path)
  end

  defp csv_file_for(amount: amount, payee: payee) do
    File.mkdir("test/sandbox")
    path = "test/sandbox/#{:random.uniform(10000)}.csv"
    write_csv_to_file(path, csv_contents(amount: amount, payee: payee))
    path
  end

  defp csv_contents(amount: amount, payee: payee) do
    [csv_head, csv_row(payee: payee, amount: amount)]
  end

  defp csv_head do
    ["Posted Date", "Reference Number", "Payee", "Address", "Amount"]
  end

  defp csv_row(payee: payee, amount: amount) do
    [posted_date, reference_number, payee, address, amount]
  end

  defp posted_date do
    Timex.format!(Timex.Date.today, "{M}/{D}/{YYYY}")
  end

  defp address do
    "ADDRESS ##{:random.uniform(10000)}"
  end

  defp reference_number do
    :random.uniform(10000)
  end

  defp attach_file(element, input) do
    session_id = Hound.current_session_id
    Hound.RequestUtils.make_req(:post, "session/#{session_id}/element/#{element}/value", %{value: ["#{input}"]})
  end

  defp write_csv_to_file(path, csv) do
    f = File.open!(path, [:write])
    CSVLixir.write(csv)
    |> Stream.each(&(IO.write(f, &1)))
    |> Stream.run
    File.close(f)
  end
end
