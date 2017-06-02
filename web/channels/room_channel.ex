defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", %{"name" => user}, socket) do
    IO.puts user<>" connected"
    send(self(),{:after_join, user})
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end




  def handle_in("alert", %{"msg" => msg}, socket) do
    IO.puts msg
    {:noreply,socket}
  end





#  def handle_in("update", _msg, socket) do
#      push socket, "update", %{value: HelloPhoenix.Players.get(), time: HelloPhoenix.Clock.get()}
#      {:noreply, socket}
#  end

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
  def handle_in("move_up", %{"name" => name}, socket) do

     HelloPhoenix.Players.move_up(%{"name" => name})
     {:noreply, socket}
  end
  def handle_in("turning_up", %{"name" => name}, socket) do
       HelloPhoenix.Players.turning_up(%{"name" => name})
       {:noreply, socket}
  end



  def terminate(_msg, _socket) do
    HelloPhoenix.Players.remove(inspect(self()))
    {:shutdown, :left}
  end

  def handle_info({:after_join, name}, socket) do
    IO.puts(inspect(self())<>" joined")
    HelloPhoenix.Players.new_player(%HelloPhoenix.Player{name: name, key: inspect(self())})
    {:noreply, socket}
  end
end