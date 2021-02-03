defmodule Buzzword.Bingo.HallWeb.PageController do
  use Buzzword.Bingo.HallWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
