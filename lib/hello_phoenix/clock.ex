defmodule HelloPhoenix.Clock do
  @span 20


  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
    Agent.start_link(fn -> %{val: 0} end,name: __MODULE__)
  end

  def init(state) do
    schedule_work(@span) # Schedule work to be performed at some point
    {:ok, state}
  end

  def get() do
    Agent.get(__MODULE__,&(&1))
  end

  def handle_info(:work, state) do
    #IO.binwrite("| ")
    time=measure(fn -> HelloPhoenix.Players.update() end)
    Agent.update(__MODULE__,&(%{&1| val: time*1000}))
    #IO.puts time
    schedule_work(@span-round(time*1000)) # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work(time) do
    Process.send_after(self(), :work,time) # In 2 hours
  end

  def measure(function) do
      function
      |> :timer.tc
      |> elem(0)
      |> Kernel./(1_000_000)
  end
end

