defmodule Buzzword.Bingo.HallWeb.GameChannel do
  use Buzzword.Bingo.HallWeb, :channel

  alias Buzzword.Bingo.Engine
  alias Buzzword.Bingo.HallWeb.Presence

  def join("games:" <> game_name, _params, socket) do
    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        self() |> send({:after_join, game_name})
        {:ok, socket}

      nil ->
        {:error, %{reason: "Game does not exist"}}
    end
  end

  def handle_info({:after_join, game_name}, socket) do
    summary = Engine.game_summary(game_name)
    :ok = push(socket, "game_summary", summary)
    :ok = push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, current_player(socket).name, %{
        # online_at: inspect(System.system_time(:seconds)),
        online_at: DateTime.utc_now() |> DateTime.to_string(),
        color: current_player(socket).color
      })

    {:noreply, socket}
  end

  def handle_in("mark_square", %{"phrase" => phrase}, socket) do
    "games:" <> game_name = socket.topic

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        summary = Engine.mark_square(game_name, phrase, current_player(socket))
        broadcast!(socket, "game_summary", summary)
        {:noreply, socket}

      nil ->
        {:reply, {:error, %{reason: "Game does not exist"}}, socket}
    end
  end

  def handle_in("new_chat_message", %{"body" => body}, socket) do
    broadcast!(socket, "new_chat_message", %{
      name: current_player(socket).name,
      body: body
    })

    {:noreply, socket}
  end

  ## Private functions

  defp current_player(socket) do
    socket.assigns.current_player
  end
end
