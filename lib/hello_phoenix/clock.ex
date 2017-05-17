defmodule HelloPhoenix.Clock do
  @span 20


  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(@span) # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    #IO.binwrite("| ")
    time=measure(fn -> HelloPhoenix.Players.update() end)
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

