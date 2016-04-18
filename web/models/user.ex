defmodule CreditCardChecker.User do
  use CreditCardChecker.Web, :model

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:email, min: 1)
    |> validate_length(:password, min: 1)
    |> only_allow_whitelisted_emails
    |> unique_constraint(:email)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end

  defp only_allow_whitelisted_emails(changeset) do
    whitelisted = Application.get_env(:credit_card_checker, :whitelisted_emails)
    if is_nil(whitelisted) do
      changeset
    else
      validate_change(changeset, :email,
        fn(:email, email) ->
          if Enum.member?(whitelisted, email) do
            []
          else
            [email: "Email is not whitelisted"]
          end
        end)
    end
  end
end
