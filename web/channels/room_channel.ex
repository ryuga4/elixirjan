defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:" <> user, message, socket) do
    IO.puts user<>" connected"
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
    {:noreply, socket}
  end
end