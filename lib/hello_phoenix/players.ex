defmodule HelloPhoenix.Players do
  alias HelloPhoenix.Player, as: Player
  @width 1000
  @height 700
  @bomb_distance 100
  @bomb_duration 10

  def start_link() do
    Agent.start_link(fn -> %{players: [], bomb: nil,time: ""} end,name: __MODULE__)
  end

  def new_player(player) do
    case players() do
        [] ->
            spawn_bomb()
            Agent.update(__MODULE__,&(%{&1 | players: [player|&1.players]}))
        _ -> Agent.update(__MODULE__,&(%{&1 | players: [player|&1.players]}))
    end
  end
  def check_bomb([]) do
    []
  end
  def check_bomb([a]) do
    [a]
  end
  def get_info() do
    Agent.get(__MODULE__,&(&1))
  end



  def spawn_bomb() do
    Agent.update(__MODULE__,&(%{&1 | bomb: [:rand.uniform(@width),:rand.uniform(@height)], time: @bomb_duration}))
    Task.start fn -> tick(@bomb_duration) end
  end

  def tick(time) do

    time2=measure(fn ->
    IO.puts time
    Agent.update(__MODULE__,&(%{&1|time: time})) end)


    cond do
     time <= 0 -> boom()
     true ->
            :timer.sleep(1000-round(time2*1000))
            tick(time-1)
    end
  end

  def boom() do
    Agent.update(__MODULE__,fn i -> %{i | players: i.players |> Enum.map(&(cond do
        &1.bomb -> &1 |> HelloPhoenix.Player.lose() |> HelloPhoenix.Player.remove_bomb() |> HelloPhoenix.Player.out_of_range()
        &1.after_bomb -> &1 |> HelloPhoenix.Player.out_of_range()
        true -> &1
        end)), bomb: nil, time: ""} end)
        spawn_bomb()
  end


  def measure(function) do
      function
      |> :timer.tc
      |> elem(0)
      |> Kernel./(1_000_000)
  end

  def check_bomb(players,nil) do players end
  def check_bomb(players,bomb) do
        new_bomber = players |> Enum.find(&(not &1.bomb and not &1.after_bomb and distance(&1.position,bomb) < @bomb_distance))
        case new_bomber do
            nil ->
             non_bomber = players |> Enum.find(&(&1.after_bomb and distance(&1.position,bomb) > @bomb_distance))
             players |> Enum.map(&(case &1 do
               ^non_bomber -> &1 |> HelloPhoenix.Player.out_of_range()
               _ -> &1
             end))
             _   ->
             after_bomber = players |> Enum.find(&(&1.bomb))
             players |> Enum.map(&(case &1 do
               ^new_bomber -> &1 |> HelloPhoenix.Player.add_bomb()
               ^after_bomber -> &1 |> HelloPhoenix.Player.remove_bomb()
               _ -> &1
             end))
        end
  end

  def check_bomb2(_players,nil) do nil end
  def check_bomb2(players,bomb) do
    bomber = players |> Enum.find(&(&1.bomb))
    case bomber do
            nil ->
                #IO.puts "No bomber"
                bomb
            %HelloPhoenix.Player{position: pos} ->
                pos
    end
  end


  def distance([a,b],[a2,b2]) do
     :math.sqrt((a-a2)*(a-a2)+(b-b2)*(b-b2))
  end




  def players() do
    Agent.get(__MODULE__, &(&1.players))
  end

  def remove(key) do
    Agent.update(__MODULE__,fn i -> %{ i | players: i.players |> Enum.filter(&(&1.key != key)) }  end)
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

  ############### STRICT
  def turn_left!(%{"name" => name}) do
      action(name,&Player.turn_left(&1))
  end
  def turn_right!(%{"name" => name}) do
      action(name,&Player.turn_right(&1))
  end
  def forward!(%{"name" => name}) do
      action(name,&Player.forward(&1))
  end
  def stop!(%{"name" => name}) do
      action(name,&Player.stop(&1))
  end
  ###############

  def update() do
    Agent.update(__MODULE__, fn i -> %{i |  players: i.players
        |> Enum.map(&(
        &1
        |> Player.check_move()
        |> Player.check_turning()
        |> Player.resistance()
        |> Player.move()
        |> Player.chech_max()
        )
        )|> check_bomb(i.bomb), bomb: check_bomb2(i.players,i.bomb)
        }end)
  end

  def action(name,func) do
    Agent.update(__MODULE__, fn i -> %{i | players: i.players
        |> Enum.map(&(case &1.name do
            name2 when name2==name -> &1 |> func.()
            _    -> &1
        end  ))}
    end)
  end


end


