defmodule CreditCardChecker.Factory do

  alias CreditCardChecker.Repo
  alias CreditCardChecker.User
  alias CreditCardChecker.PaymentMethod
  alias CreditCardChecker.Expense
  alias CreditCardChecker.Merchant
  alias CreditCardChecker.StatementLine
  alias CreditCardChecker.Transaction

  def create_user(%{email: _, password: _} = credentials) do
    %User{}
    |> User.changeset(credentials)
    |> Repo.insert!
  end

  def create_payment_method(attrs, user: %User{id: user_id}) when user_id != nil do
    attrs = Map.put_new(attrs, :user_id, user_id)
    PaymentMethod.changeset(%PaymentMethod{}, attrs)
    |> Repo.insert!
  end

  def create_expense(%{amount: amount} = attrs, opts) do
    attrs
    |> Map.delete(:amount)
    |> Map.put(:amount_in_cents, round(amount * 100))
    |> create_expense(opts)
  end

  def create_expense(attrs,
                     payment_method: %PaymentMethod{id: payment_method_id},
                     merchant: %Merchant{id: merchant_id},
                     user: %User{id: user_id}) do
    default_attrs = %{payment_method_id: payment_method_id,
                      merchant_id: merchant_id,
                      user_id: user_id,
                      time_of_sale: now}
    Expense.changeset(%Expense{}, Map.merge(default_attrs, attrs))
    |> Repo.insert!
  end

  def create_expense(attrs, user: user) do
    payment_method = create_payment_method(%{name: "Some PM"}, user: user)
    merchant = create_merchant(%{name: "Some Merchant"}, user: user)
    create_expense(attrs, payment_method: payment_method, merchant: merchant,
                    user: user)
  end

  def create_merchant(attrs, user: %User{id: user_id}) do
    attrs = Map.put_new(attrs, :user_id, user_id)
    Merchant.changeset(%Merchant{}, attrs)
    |> Repo.insert!
  end

  def create_statement_line(%{amount: amount} = attrs, opts) do
    attrs
    |> Map.delete(:amount)
    |> Map.put(:amount_in_cents, round(amount * 100))
    |> create_statement_line(opts)
  end

  def create_statement_line(attrs, payment_method: %PaymentMethod{id: payment_method_id}) do
    attrs = Map.merge(attrs, %{
      posted_date: Ecto.Date.cast!("2016-04-20"),
      reference_number: "123456",
      payment_method_id: payment_method_id
    })
    StatementLine.changeset(%StatementLine{}, attrs)
    |> Repo.insert!
  end

  def create_statement_line(attrs) do
    user = create_user(%{email: "somebody@example.com", password: "secret"})
    payment_method = create_payment_method(%{name: "Visa"}, user: user)
    create_statement_line(attrs, payment_method: payment_method)
  end

  def create_transaction(statement_line: statement_line, expense: expense) do
    attrs = %{statement_line_id: statement_line.id, expense_id: expense.id}
    Transaction.changeset(%Transaction{}, attrs)
    |> Repo.insert!
  end

  defp now do
    Timex.DateTime.local
    |> Timex.Timezone.convert("America/Los_Angeles")
    |> Timex.to_erlang_datetime
  end
end
