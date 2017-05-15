defmodule HelloPhoenix.State do





      def start_link() do
        Agent.start_link(fn -> %{value: 0} end, name: __MODULE__)
      end




      def put(value) do
        Agent.update(__MODULE__, &Map.put(&1, :value, value))
      end

      def get() do
        Agent.get(__MODULE__,&Map.get(&1, :value))
      end

      def inc() do
        value = get()
        Agent.update(__MODULE__, &Map.put(&1,:value,value+1))
      end

end