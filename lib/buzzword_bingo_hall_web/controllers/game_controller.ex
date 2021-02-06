defmodule Buzzword.Bingo.HallWeb.GameController do
  use Buzzword.Bingo.HallWeb, :controller

  alias Buzzword.Bingo.Engine

  @salt Application.get_env(:buzzword_bingo_hall, :salt)

  plug :require_player

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"game" => %{"size" => size}}) do
    game_name = Engine.haiku_name()
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
      # Game is still running...
      pid when is_pid(pid) ->
        conn
        # Allows next player to join game from other tabs of same browser...
        |> delete_session(:current_player)
        |> assign(:game_name, game_name)
        |> assign(:auth_token, generate_auth_token(conn))
        |> render("show.html")

      # Game has likely timed out...
      nil ->
        conn
        |> put_flash(:error, "Game not found!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  ## Private functions

  defp require_player(conn, _opts) do
    case get_session(conn, :current_player) do
      nil ->
        conn
        |> put_session(:return_to, conn.request_path)
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()

      _current_player ->
        conn
    end
  end

  @spec generate_auth_token(Plug.Conn.t()) :: String.t()
  defp generate_auth_token(conn) do
    current_player = get_session(conn, :current_player)
    Phoenix.Token.sign(conn, @salt, current_player)
  end
end
