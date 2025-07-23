defmodule HinomixWeb.Router do
  use HinomixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Mock third-party API endpoints
  scope "/third-party-api/v1", HinomixWeb do
    pipe_through :api
    
    get "/reports", ThirdPartyApiController, :reports
  end
end