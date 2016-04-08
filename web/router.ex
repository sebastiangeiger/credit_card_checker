defmodule CreditCardChecker.Router do
  use CreditCardChecker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CreditCardChecker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/payment_methods", PaymentMethodController
    resources "/merchants", MerchantController
    resources "/expenses", ExpenseController, only: [:new, :create, :index, :show, :delete]
    resources "/sessions", SessionController, only: [:new]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CreditCardChecker do
  #   pipe_through :api
  # end
end
