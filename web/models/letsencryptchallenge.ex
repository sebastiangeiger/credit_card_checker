defmodule CreditCardChecker.Letsencryptchallenge do
  use CreditCardChecker.Web, :model

  schema "letsencryptchallenges" do
    field :challenge, :string
    field :response, :string
  end

  @required_fields ~w(challenge response)
  @optional_fields ~w()

  def changeset(model, params, opts \\ []) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
