defmodule HelloPhoenix.HelloController do
  use HelloPhoenix.Web, :controller




  def index(conn, _params) do
    render conn, "index.html"
  end
  def show(conn, %{"messenger" => messenger}) do
    render conn, "show.html", messenger: messenger
  end
  def add(conn, %{"value" => value}) do
      conn
      |> put_layout("admin.html")
      |> render("add.html", value: String.to_integer(value)+1)
      #render conn, "add.html", value: String.to_integer(value)+1
  end
end