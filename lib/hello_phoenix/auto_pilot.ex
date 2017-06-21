defmodule AutoPilot do
  @moduledoc false
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
    Agent.start_link(fn -> [] end,name: __MODULE__)
  end
end