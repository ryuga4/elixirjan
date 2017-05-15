defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", message, socket) do
    Logger.info "Joined"
    Logger.debug "Message: #{message}\n Socket: #{socket}"
    send(self(),{:after_join, message})
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_in("update", %{"body" => body}, socket) do
      value=HelloPhoenix.State.get()
      IO.puts value
      broadcast! socket, "inc", %{value: value}
      {:noreply, socket}
  end

  def handle_out("update", payload, socket) do
      push socket, "update", payload
      {:noreply, socket}
  end

  def handle_info({:after_join, _message}, socket) do

    #HelloPhoenix.State.start_link()
    #HelloPhoenix.State.inc()
    value=HelloPhoenix.State.get()
    broadcast! socket, "inc", %{value: value}
    {:noreply, socket}
  end
end