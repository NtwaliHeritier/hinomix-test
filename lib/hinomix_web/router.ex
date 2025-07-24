defmodule HinomixWeb.Router do
  use HinomixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HinomixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Mock third-party API endpoints
  scope "/third-party-api/v1", HinomixWeb do
    pipe_through :api

    get "/reports", ThirdPartyApiController, :reports
  end

  scope "/", HinomixWeb do
    pipe_through :browser

    live "/reports", ReportsLive
  end
end
