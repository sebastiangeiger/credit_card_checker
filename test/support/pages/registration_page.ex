defmodule RegistrationPage do
  use PageObject

  visitable :visit, "http://localhost:4001/users/new"
  clickable :submit, "input[value='Register']"

  fillable :fill_email, "input[id='user_email']"

  fillable :fill_password, "input[id='user_password']"

  def register_as(%{email: email, password: password}) do
    visit
    fill_email(email)
    fill_password(password)
    submit
  end
end
