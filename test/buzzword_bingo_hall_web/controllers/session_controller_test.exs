defmodule Buzzword.Bingo.HallWeb.SessionControllerTest do
  use Buzzword.Bingo.HallWeb.ConnCase

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))

      assert html_response(conn, 200) =~ "Play Bingo"
    end
  end

  describe "create session" do
    test "adds player to session", %{conn: conn} do
      attrs = %{"name" => "mike", "color" => "blue"}

      conn = post(conn, Routes.session_path(conn, :create), player: attrs)

      expected_player = %Buzzword.Bingo.Player{name: "mike", color: "blue"}

      assert Plug.Conn.get_session(conn, :current_player) == expected_player

      assert redirected_to(conn) == Routes.game_path(conn, :new)
    end
  end

  describe "delete session" do
    test "deletes player from session", %{conn: conn} do
      conn = put_player_in_session(conn, "mike")

      conn = delete(conn, Routes.session_path(conn, :delete))

      assert redirected_to(conn) == "/"

      assert Plug.Conn.get_session(conn, :current_player) == nil
    end
  end
end
