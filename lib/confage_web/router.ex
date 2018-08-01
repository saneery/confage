defmodule ConfageWeb.Router do
  use ConfageWeb, :router

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

  scope "/api", ConfageWeb do
    pipe_through :api

    get "/apps", ApiController, :app_list
    post "/apps/create", ApiController, :create_app
    delete "/apps/:name", ApiController, :delete_app
    get "/apps/:name/config", ApiController, :app_config
    post "/apps/:name/config", ApiController, :set_config
  end

  scope "/", ConfageWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
