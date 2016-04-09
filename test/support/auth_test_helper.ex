defmodule CreditCardChecker.AuthTestHelper do
  use Hound.Helpers

  @endpoint CreditCardChecker.Endpoint
  @credentials %{email: "email@example.com", password: "super_secret"}

  import Phoenix.ConnTest, only: [post: 3]
  import CreditCardChecker.Router.Helpers, only: [session_path: 2]

  def sign_in(conn) do
    create_user(@credentials)
    session_params = [session: @credentials]
    post conn, session_path(conn, :create), session_params
  end

  def sign_in_through_app do
    create_user(@credentials)
    sign_in_through_app(@credentials)
  end

  def sign_in_through_app(%{email: email, password: password}) do
    navigate_to("/sessions/new")
    find_element(:css, "input#session_email")
    |> fill_field(email)
    find_element(:css, "input#session_password")
    |> fill_field(password)
    find_element(:css, "input[value='Sign In']")
    |> submit_element
  end

  def sign_out_through_app do
    navigate_to("/sessions/new")
    sign_out_links = find_all_elements(:link_text, "Sign Out")
    if Enum.count(sign_out_links) > 0 do
      sign_out_links
      |> List.first
      |> click
    end
  end

  def create_user(%{email: _, password: _} = credentials) do
    %CreditCardChecker.User{}
    |> CreditCardChecker.User.changeset(credentials)
    |> CreditCardChecker.Repo.insert!
  end
end
