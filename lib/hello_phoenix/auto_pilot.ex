defmodule AutoPilot do
  @moduledoc false
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
    Agent.start_link(fn -> [] end,name: __MODULE__)
  end

  def add_player(%HelloPhoenix.Player{name: name}) do
    Agent.update(__MODULE__,&([name,&1]))
  end


end