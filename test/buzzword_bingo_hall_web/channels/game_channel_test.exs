defmodule Buzzword.Bingo.HallWeb.GameChannelTest do
  use Buzzword.Bingo.HallWeb.ChannelCase

  alias Buzzword.Bingo.HallWeb.{GameChannel, UserSocket}
  alias Buzzword.Bingo.{Engine, Player}

  @salt :application.get_env(:buzzword_bingo_hall, :salt)
  @salt elem(@salt, 1)

  setup do
    game_name = "test-game-123"
    topic = "games:#{game_name}"
    Engine.new_game(game_name, 3)
    player = Player.new("nicole", "green")
    token = socket(UserSocket) |> Phoenix.Token.sign(@salt, player)
    {:ok, socket} = connect(UserSocket, %{"token" => token})

    [
      game_name: game_name,
      topic: topic,
      socket: socket,
      player: player
    ]
  end

  describe "join" do
    test "pushes the current game and presence state", context do
      {:ok, _reply, _socket} =
        subscribe_and_join(context.socket, GameChannel, context.topic, %{})

      assert context.socket.assigns.current_player == context.player
      assert_push("presence_state", %{})
      summary = Engine.game_summary(context.game_name)
      assert_push("game_summary", ^summary)
    end

    test "returns error if game does not exist", context do
      assert {:error, %{reason: "Game does not exist"}} =
               subscribe_and_join(
                 context.socket,
                 GameChannel,
                 "games:9999",
                 %{}
               )
    end
  end

  describe "mark_square" do
    test "broadcasts the new game summary", context do
      {:ok, _reply, socket} =
        subscribe_and_join(context.socket, GameChannel, context.topic, %{})

      summary = Engine.game_summary(context.game_name)
      square_to_mark = square_at_position(summary.squares, 0, 0)
      push(socket, "mark_square", %{phrase: square_to_mark.phrase})
      assert_broadcast("game_summary", %{})
    end

    test "returns nil if game does not exist", context do
      {:ok, _reply, socket} =
        subscribe_and_join(context.socket, GameChannel, context.topic, %{})

      pid = Engine.game_pid(context.game_name)
      Process.exit(pid, :kill)
      ref = push(socket, "mark_square", %{phrase: "A"})
      assert_reply(ref, :error, %{reason: "Game does not exist"})
    end
  end

  describe "new_chat_message" do
    test "broadcasts message to game channel", context do
      {:ok, _reply, socket} =
        subscribe_and_join(context.socket, GameChannel, context.topic, %{})

      reply = %{
        name: context.player.name,
        body: "Hello!"
      }

      push(socket, "new_chat_message", reply)
      assert_broadcast("new_chat_message", ^reply)
    end
  end

  defp square_at_position(squares, row, col) do
    squares |> Enum.at(row) |> Enum.at(col)
  end
end
