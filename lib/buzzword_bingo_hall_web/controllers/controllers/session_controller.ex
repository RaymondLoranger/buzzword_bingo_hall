defmodule Buzzword.Bingo.HallWeb.SessionController do
  use Buzzword.Bingo.HallWeb, :controller

  alias Buzzword.Bingo.Player

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"player" => %{"name" => name, "color" => color}}) do
    player = Player.new(name, color)

    conn
    |> put_session(:current_player, player)
    |> redirect_back_or_to_new_game
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_player)
    |> redirect(to: "/")
  end

  ## Private functions

  defp redirect_back_or_to_new_game(conn) do
    path = get_session(conn, :return_to) || Routes.game_path(conn, :new)

    conn
    |> put_session(:return_to, nil)
    |> redirect(to: path)
  end
end
