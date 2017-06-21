defmodule HelloPhoenix.KreiserController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    conn
        |> put_layout(false)
        |> render("whoacalendar.html")
  end

end