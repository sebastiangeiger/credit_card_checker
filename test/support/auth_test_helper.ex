defmodule CreditCardChecker.AuthTestHelper do
  use Hound.Helpers

  @endpoint CreditCardChecker.Endpoint

  import Phoenix.ConnTest, only: [post: 3]
  import CreditCardChecker.Router.Helpers, only: [session_path: 2]

  def sign_in(conn) do
    session_params = [session: %{email: "email@example.com",
                                 password: "super_secret"}]
    post conn, session_path(conn, :create), session_params
  end

  def sign_in_through_app do
    navigate_to("/sessions/new")
    find_element(:css, "input#session_email")
    |> fill_field("email@example.com")
    find_element(:css, "input#session_password")
    |> fill_field("super_secret")
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
end
