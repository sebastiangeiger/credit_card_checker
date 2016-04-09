defmodule CreditCardChecker.UserTestHelper do
  use Hound.Helpers

  def register_as(%{email: email, password: password}) do
    navigate_to("/")
    find_element(:link_text, "Sign In")
    |> click
    find_element(:link_text, "Register")
    |> click
    find_element(:css, "input#user_email")
    |> fill_field(email)
    find_element(:css, "input#user_password")
    |> fill_field(password)
    find_element(:css, "input[value='Register']")
    |> submit_element
  end
end
