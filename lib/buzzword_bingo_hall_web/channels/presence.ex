defmodule Buzzword.Bingo.HallWeb.Presence do
  use Phoenix.Presence,
    otp_app: :buzzword_bingo_hall,
    pubsub_server: Buzzword.Bingo.Hall.PubSub
end
