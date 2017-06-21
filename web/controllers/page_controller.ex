defmodule HelloPhoenix.PageController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    conn
    #|> put_layout(false)
    |> render(:index)
  end
end
