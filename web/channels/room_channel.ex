defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", message, socket) do
    Logger.info "Joined"
    Logger.debug "Message: coś"
    send(self(),{:after_join, message})
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end




  def handle_in("alert", %{"msg" => msg}, socket) do
    IO.puts msg
    {:noreply,socket}
  end



  def handle_in("update", %{"body" => body}, socket) do
      number=HelloPhoenix.State.get()
      value=HelloPhoenix.Players.get()
      #HelloPhoenix.Players.update()

      #IO.puts value
      #broadcast! socket, "inc", %{value: number}
      broadcast! socket, "update", %{value: value}
      {:noreply, socket}
  end

#  def handle_out("update", payload, socket) do
#      push socket, "update", payload
#      {:noreply, socket}
#  end






  def handle_in("turn_left", %{"name" => name}, socket) do
     HelloPhoenix.Players.turn_left(%{"name" => name})
     {:noreply, socket}
  end
  def handle_in("turn_right", %{"name" => name}, socket) do
     HelloPhoenix.Players.turn_right(%{"name" => name})
     {:noreply, socket}
  end
  def handle_in("forward", %{"name" => name}, socket) do
     HelloPhoenix.Players.forward(%{"name" => name})
     {:noreply, socket}
  end
  def handle_in("stop", %{"name" => name}, socket) do
       HelloPhoenix.Players.stop(%{"name" => name})
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