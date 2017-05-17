defmodule HelloPhoenix.Players do
  alias HelloPhoenix.Player, as: Player

  def start_link() do
    Agent.start_link(fn -> [] end,name: __MODULE__)
  end

  def new_player(player) do
    Agent.update(__MODULE__,&([player|&1]))
  end


  def get() do
    Agent.get(__MODULE__, &(&1))
  end

  def forward(%{"name" => name}) do
    action(name,&Player.forward(&1))
  end

  def turn_left(%{"name" => name}) do
    action(name,&Player.turn_left(&1))
  end

  def turn_right(%{"name" => name}) do
    action(name,&Player.turn_right(&1))
  end

  def stop(%{"name" => name}) do
    action(name,&Player.stop(&1))
  end

  def update() do
    Agent.update(__MODULE__, fn i -> i
        |> Enum.map(&(
        &1
        |> Player.resistance()
        |> Player.move()
        |> Player.chech_max()
        ))
    end)
  end

  def action(name,func) do
    Agent.update(__MODULE__, fn i -> i
        |> Enum.map(&(case &1.name do
            name2 when name2==name -> &1 |> func.()
            _    -> &1
        end  ))
    end)
  end


end


