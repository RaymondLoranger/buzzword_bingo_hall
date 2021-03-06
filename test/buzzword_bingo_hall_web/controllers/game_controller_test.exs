defmodule Buzzword.Bingo.HallWeb.GameControllerTest do
  use Buzzword.Bingo.HallWeb.ConnCase

  alias Buzzword.Bingo.Engine

  describe "new" do
    test "redirects to new session if not authenticated", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :new))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "renders new game form if authenticated", %{conn: conn} do
      conn = put_player_in_session(conn, "mike")
      conn = get(conn, Routes.game_path(conn, :new))
      assert html_response(conn, 200) =~ "Start Game"
    end
  end

  describe "create" do
    test "redirects to new session if not authenticated", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "redirects to show game if authenticated", %{conn: conn} do
      conn = put_player_in_session(conn, "mike")
      conn = post(conn, Routes.game_path(conn, :create), game: %{"size" => "3"})
      assert %{id: game_name} = redirected_params(conn)
      assert redirected_to(conn) == Routes.game_path(conn, :show, game_name)
      conn = get(conn, Routes.game_path(conn, :show, game_name))
      assert html_response(conn, 200) =~ "game-container"
    end
  end

  describe "show" do
    test "redirects to new session if not authenticated", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :show, "123"))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "redirects to new game if game does not exist", %{conn: conn} do
      conn = put_player_in_session(conn, "mike")
      conn = get(conn, Routes.game_path(conn, :show, "nonexistent-game"))
      assert redirected_to(conn) == Routes.game_path(conn, :new)
    end

    test "shows game if it exists", %{conn: conn} do
      conn = put_player_in_session(conn, "mike")
      game_name = start_game()
      conn = get(conn, Routes.game_path(conn, :show, game_name))
      assert html_response(conn, 200) =~ game_name
    end
  end

  defp start_game do
    game_name = Engine.haiku_name()
    {:ok, _pid} = Engine.new_game(game_name, 3)
    game_name
  end
end
