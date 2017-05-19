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

  def remove(key) do
    Agent.update(__MODULE__,fn i -> i |> Enum.filter(&(&1.key != key)) end)
  end

  def move_up(%{"name" => name}) do
    action(name,&Player.set_move(&1,:none))
  end
  def turning_up(%{"name" => name}) do
    action(name,&Player.set_turning(&1,:none))
  end

  def forward(%{"name" => name}) do
    action(name,&Player.set_move(&1,:forward))
  end

  def turn_left(%{"name" => name}) do
    action(name,&Player.set_turning(&1,:left))
  end

  def turn_right(%{"name" => name}) do
    action(name,&Player.set_turning(&1,:right))
  end

  def stop(%{"name" => name}) do
    action(name,&Player.set_move(&1,:stop))
  end

  def update() do
    Agent.update(__MODULE__, fn i -> i
        |> Enum.map(&(
        &1
        |> Player.check_move()
        |> Player.check_turning()
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


