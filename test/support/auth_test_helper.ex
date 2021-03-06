defmodule CreditCardChecker.AuthTestHelper do
  use Hound.Helpers

  @endpoint CreditCardChecker.Endpoint
  @credentials %{email: "email@example.com", password: "super_secret"}

  import Phoenix.ConnTest, only: [post: 3]
  import CreditCardChecker.Router.Helpers, only: [session_path: 2]
  import CreditCardChecker.Factory, only: [create_user: 1]

  alias CreditCardChecker.User

  def sign_in(conn) do
    create_user(@credentials)
    session_params = [session: @credentials]
    post conn, session_path(conn, :create), session_params
  end

  def sign_in(conn, %User{email: email, password: password}) do
    session_params = [session: %{email: email,
                                 password: password}]
    post conn, session_path(conn, :create), session_params
  end

  def sign_in_through_app do
    create_user(@credentials)
    SignInPage.sign_in_through_app(@credentials)
  end
end
