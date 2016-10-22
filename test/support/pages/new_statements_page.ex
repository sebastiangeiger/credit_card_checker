defmodule NewStatementsPage do
  use PageObject
  alias PaymentMethodsPage.PaymentMethods

  clickable :upload, "input[value='Upload']"

  def create(%{amount: amount, payee: payee,
    payment_method: %{name: payment_method_name}}) do
    file_path = __MODULE__.StatementFile.for(amount: amount, payee: payee)
    visit(name: payment_method_name)
    find_element(:css, "input#statement_file")
    |> attach_file(file_path)
    upload
    File.rm(file_path)
  end

  def visit(name: payment_method_name) do
    PaymentMethodsPage.visit
    PaymentMethods.all
    |> Enum.find(&(PaymentMethods.name(&1) == payment_method_name))
    |> PaymentMethods.click_upload
  end

  defp attach_file(element, input) do
    session_id = Hound.current_session_id
    Hound.RequestUtils.make_req(:post, "session/#{session_id}/element/#{element}/value", %{value: ["#{input}"]})
  end


  defmodule StatementFile do
    def for(amount: amount, payee: payee) do
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

    defp write_csv_to_file(path, csv) do
      f = File.open!(path, [:write])
      CSVLixir.write(csv)
      |> Stream.each(&(IO.write(f, &1)))
      |> Stream.run
      File.close(f)
    end
  end
end
