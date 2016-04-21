defmodule CreditCardChecker.Router do
  use CreditCardChecker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CreditCardChecker.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CreditCardChecker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/payment_methods", PaymentMethodController, only: [:new, :create, :index, :show] do
      resources "/statements", StatementController, only: [:new, :create]
    end
    resources "/merchants", MerchantController
    resources "/expenses", ExpenseController, only: [:new, :create, :index, :show, :delete]
    resources "/sessions", SessionController, only: [:new, :create]
    delete "/sessions", SessionController, :delete
    resources "/users", UserController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CreditCardChecker do
  #   pipe_through :api
  # end
end
