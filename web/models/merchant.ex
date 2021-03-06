defmodule CreditCardChecker.Merchant do
  use CreditCardChecker.Web, :model

  schema "merchants" do
    field :name, :string
    belongs_to :user, CreditCardChecker.User

    timestamps
  end

  @required_fields ~w(name user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> validate_format(:name, ~r/\S+/)
  end

  def names_for(user_id: user_id) do
    from m in CreditCardChecker.Merchant,
    select: m.name,
    where: m.user_id == ^user_id,
    order_by: m.name
  end
end
