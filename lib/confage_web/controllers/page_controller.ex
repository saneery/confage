defmodule ConfageWeb.PageController do
  use ConfageWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
