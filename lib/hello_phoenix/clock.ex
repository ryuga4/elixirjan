defmodule HelloPhoenix.Clock do
  @span 10


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
    %{players: players, bomb: bomb,time: time2} = HelloPhoenix.Players.get_info()
    time=measure(fn -> HelloPhoenix.Players.update()
                       HelloPhoenix.AutoPilot.moveall(players)
                       end)


    HelloPhoenix.Endpoint.broadcast("room:lobby", "update", %{value: players, bomb: bomb,time: time2,timeSERWER: time})
    #IO.puts(time)
    schedule_work(case @span-round(time*1000) do
                x when x>0 -> x
                x when x<=0 -> 0
    end) # Reschedule once more

    {:noreply, state}
  end

  defp schedule_work(time) do
    Process.send_after(self(), :work,time)
  end

  

  def measure(function) do
      function
      |> :timer.tc
      |> elem(0)
      |> Kernel./(1_000_000)
  end
end

