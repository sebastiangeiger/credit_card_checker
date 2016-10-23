defmodule SignInPage do
  use PageObject

  visitable :visit, "http://localhost:4001/sessions/new"
  clickable :submit, "input[value='Sign In']"

  fillable :fill_email, "input[id='session_email']"

  fillable :fill_password, "input[id='session_password']"

  def sign_in_through_app(%{email: email, password: password}) do
    visit
    fill_email(email)
    fill_password(password)
    submit
  end
end
