defmodule HelloPhoenix.AutoPilot do
  @moduledoc false
  use GenServer
  @width 1000
  @height 700
  @border 50
  def start_link() do
    GenServer.start_link(__MODULE__, %{})
    Agent.start_link(fn -> %{names: []} end,name: __MODULE__)
  end

  def init(state) do
     # Schedule work to be performed at some point
    {:ok, state}
  end

  def add_player(name) do
    Agent.update(__MODULE__,&(%{&1 | names: [name|&1.names]}))
  end







  def moveall(players) do
    Agent.get(__MODULE__,&(&1.names)) |> Enum.each(fn i -> move(i,players) end)
  end

  def move(name,players_all) do
    players = players_all |> Enum.filter(&(&1.name != name))
    player  = players_all |> Enum.find(&(&1.name == name))
    case player do
     nil -> nil
     _ -> case player.bomb do
        true -> chase(player,players)
        false -> run_away2(player,Enum.find(players,&(&1.bomb)))
        end
    end
  end

  def chase(player,players) do
    min_dist=players |> Enum.map(&(distance(player.position,&1.position))) |> Enum.min()


    player2=Enum.find(players,&(distance(player.position,&1.position) == min_dist))
    [x,y]=moving_to(player2)
    #[x,y]=player2.position
    player |> turn_to([x,y])
    HelloPhoenix.Players.forward!(%{"name" => player.name})
  end



  def run_away2(_,nil) do nil end
  def run_away2(player,bomber) do
    #IO.inspect(wypadkowa(player,bomber))

    player |> turn_to(wypadkowa(player,bomber))
    HelloPhoenix.Players.forward!(%{"name" => player.name})
  end




  def borders2([x0,y0]) do
    walls=HelloPhoenix.Wall.walls()
    walls
    |> List.foldl([x0,y0],fn wall,[x,y] ->
     case HelloPhoenix.Wall.distance([x,y],wall)>10 do
        true ->[x,y]
        false ->HelloPhoenix.Wall.block([x,y],wall)
        end
     end)
  end

  def distance([a,b],[a2,b2]) do
    :math.sqrt((a-a2)*(a-a2)+(b-b2)*(b-b2))
  end
  def moving_to(%HelloPhoenix.Player{position: [posx,posy], velocity: [velx,vely]}) do
    coords=[posx+10*velx,posy+10*vely]
    borders2(coords)
  end

  def turn_to(%HelloPhoenix.Player{angle: angle, position: [x0,y0]}=player,[x,y]) do

    {x1,y1}={x0+:math.cos(angle-:math.pi/45),y0+:math.sin(angle-:math.pi/45)}
    {x2,y2}={x0+:math.cos(angle+:math.pi/45),y0+:math.sin(angle+:math.pi/45)}

    case distance([x,y],[x1,y1])-distance([x,y],[x2,y2]) do
      some when some < -0.001 ->
            #IO.puts "siema"
            %{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
      some when some > 0.001 ->
            #IO.puts "siema2"
            %{"name" => player.name} |> HelloPhoenix.Players.turn_right!()
      _ -> nil
    end


  end
  def supercalc([x1,y1]=v1,[x2,y2]=v2) do
    case distance(v1,v2) do
        dist when dist > 5 ->  x=(x1-x2)*100/:math.pow(dist,2)
                               y=(y1-y2)*100/:math.pow(dist,2)
                               [x,y]
        dist -> [0,0]
  end


  end

  def wypadkowa(%HelloPhoenix.Player{position: [x1,y1]},%HelloPhoenix.Player{position: [x0,y0],velocity: [vx,vy]}) do
    {x2,y2}={x0+20*vx,y0+20*vy}
    walls=HelloPhoenix.Wall.walls()
    #IO.inspect([x1,y1])
    [w1,w2,w3,w4]=walls
    points = walls |> Enum.map(&(HelloPhoenix.Wall.closest_point([x1,y1],&1)))
    #IO.inspect([x1,y1])
    [x,y]=points ++ [[x2,y2]]
              |> Enum.map(&(supercalc([x1,y1],&1)))
              |> Enum.reduce(fn [xi,yi],[xa,ya] -> [xa+xi,ya+yi] end)
    [x1+x,y1+y]

  end

end