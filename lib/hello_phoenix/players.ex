defmodule HelloPhoenix.Players do
  alias HelloPhoenix.Player, as: Player

  @bomb_distance 100


  def start_link() do
    Agent.start_link(fn -> [] end,name: __MODULE__)
  end

  def new_player(player) do
    case get() do
        [] -> Agent.update(__MODULE__,&([HelloPhoenix.Player.add_bomb(player)|&1]))
        _ -> Agent.update(__MODULE__,&([player|&1]))
    end
  end
  def check_bomb([]) do
    []
  end
  def check_bomb([a]) do
      [a]
  end

  def check_bomb(players) do

    bomber = players |> Enum.find(&(&1.bomb))
    case bomber do
        nil ->
            #IO.puts "No bomber"
            players
        %HelloPhoenix.Player{position: pos, name: name} ->
            victim = players |> Enum.filter(&(&1.name != name) and (not &1.after_bomb)) |> Enum.find(&(distance(pos,&1.position)<@bomb_distance))
            case victim do
                nil ->
                    #IO.puts "No victim"
                    players |> Enum.map(&(cond do
                      &1.after_bomb and distance(&1.position,pos)>@bomb_distance ->
                        &1 |> HelloPhoenix.Player.out_of_range()
                      true -> &1
                    end))
                %HelloPhoenix.Player{position: pos2, name: name2} ->
                    out_of_ramge=distance(pos,pos2)>@bomb_distance
                    players |> Enum.map(&(cond do
                        &1.after_bomb and distance(&1.position,pos)>@bomb_distance ->
                            &1 |> HelloPhoenix.Player.out_of_range()
                        &1.name==name2 ->
                            IO.puts "#{name2} got bomb"
                             &1 |> HelloPhoenix.Player.add_bomb()
                        &1.name==name ->
                            IO.puts "#{name} lost bomb"
                            &1 |> HelloPhoenix.Player.remove_bomb()
                        true ->
                            IO.puts "none"
                            &1
                    end))
            end
    end
  end


  def distance([a,b],[a2,b2]) do
     :math.sqrt((a-a2)*(a-a2)+(b-b2)*(b-b2))
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
        )
        )|> check_bomb()
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


