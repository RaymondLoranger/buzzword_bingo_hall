defmodule Buzzword.Bingo.HallWeb.GameView do
  use Buzzword.Bingo.HallWeb, :view

  # alias Buzzword.Bingo.HallWeb.Endpoint

  def grid_glyph(size) do
    content_tag :div, class: "grid-glyph" do
      for _row <- 1..size do
        content_tag :div, class: "row" do
          for _col <- 1..size do
            content_tag(:span, "", class: "box")
          end
        end
      end
    end
  end

  # For Elm front-end only.
  # def ws_url do
  #   System.get_env("WS_URL") || Endpoint.config(:ws_url)
  # end
end
