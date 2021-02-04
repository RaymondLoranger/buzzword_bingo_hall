defmodule Buzzword.Bingo.HallWeb.GameController do
  use Buzzword.Bingo.HallWeb, :controller

  alias Buzzword.Bingo.{Engine, Game}

  @salt Application.get_env(:buzzword_bingo_hall, :salt)

  plug :require_player

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"game" => %{"size" => size}}) do
    game_name = Game.haiku_name()
    size = String.to_integer(size)

    case Engine.new_game(game_name, size) do
      {:ok, _game_pid} ->
        redirect(conn, to: Routes.game_path(conn, :show, game_name))

      {:error, _error} ->
        conn
        |> put_flash(:error, "Unable to start game!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  def show(conn, %{"id" => game_name}) do
    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        conn
        |> assign(:game_name, game_name)
        |> assign(:auth_token, generate_auth_token(conn))
        |> render("show.html")

      nil ->
        conn
        |> put_flash(:error, "Game not found!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  ## Private functions

  defp require_player(conn, _opts) do
    if get_session(conn, :current_player) do
      conn
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  defp generate_auth_token(conn) do
    current_player = get_session(conn, :current_player)
    Phoenix.Token.sign(conn, @salt, current_player)
  end
end
