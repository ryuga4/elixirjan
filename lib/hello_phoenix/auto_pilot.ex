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

  def run_away(_,nil) do nil end
  def run_away(player,bomber) do
     [x,y]=moving_to(bomber)
     [x0,y0]=player.position

     dox = cond do
       x0 >= @border and x0 < @width-@border -> :yes
       x0 < @border -> {x1,x2}={x0+:math.cos(player.angle-:math.pi/45),x0+:math.cos(player.angle+:math.pi/45)}
               case x1-x2 do
                  some when some < 0 -> %{"name" => player.name} |> HelloPhoenix.Players.turn_right!()
                  _ -> %{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
               end
       x0 > @width-@border -> {x1,x2}={x0+:math.cos(player.angle-:math.pi/45),x0+:math.cos(player.angle+:math.pi/45)}
               case x1-x2 do
                  some when some < 0 -> %{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
                  _ -> %{"name" => player.name} |> HelloPhoenix.Players.turn_right!()
               end
       true -> :yes
     end

      doy = cond do
       y0 >= @border and y0 < @height-@border -> :yes
       y0 < @border -> {y1,y2}={y0+:math.sin(player.angle-:math.pi/45),y0+:math.sin(player.angle-:math.pi/45)}
               case y1-y2 do
                 some when some < 0 -> %{"name" => player.name} |> HelloPhoenix.Players.turn_right!()
                 _ -> %{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
               end
       y0 > @height-@border -> {y1,y2}={y0+:math.sin(player.angle-:math.pi/45),y0+:math.sin(player.angle-:math.pi/45)}
               case y1-y2 do
                 some when some < 0 -> %{"name" => player.name} |> HelloPhoenix.Players.turn_right!()
                 _ -> %{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
               end
       true -> :yes
     end
     finaly = 2*y0 - y
     finalx = 2*x0 - x

     #if((doy == :yes and dox != :yes) or (doy != :yes and dox == :yes)) do player |> turn_to([finalx,finaly]) end
     case {doy,dox} do
        {:yes,:yes} -> player |> turn_to([finalx,finaly])
                       HelloPhoenix.Players.forward!(%{"name" => player.name})
        {:yes, _} -> HelloPhoenix.Players.forward!(%{"name" => player.name})
        {_,:yes} -> HelloPhoenix.Players.forward!(%{"name" => player.name})
        {_,_} ->    %{"name" => player.name} |> HelloPhoenix.Players.stop!()
                    #%{"name" => player.name} |> HelloPhoenix.Players.turn_left!()
     end

  end

  def run_away2(_,nil) do nil end
  def run_away2(player,bomber) do
    #IO.inspect(wypadkowa(player,bomber))

    player |> turn_to(wypadkowa(player,bomber))
    HelloPhoenix.Players.forward!(%{"name" => player.name})
  end

  def borders(x0,y0) do
    x = cond do
        x0 < 0 -> 0
        x0 > @width -> @width
        true -> x0
    end
    y = cond do
        y0 < 0 -> 0
        y0 > @height -> @height
        true -> y0
    end
    [x,y]
  end
  def distance([a,b],[a2,b2]) do
    :math.sqrt((a-a2)*(a-a2)+(b-b2)*(b-b2))
  end
  def moving_to(%HelloPhoenix.Player{position: [posx,posy], velocity: [velx,vely]}) do
    {x,y}={posx+10*velx,posy+10*vely}
    borders(x,y)
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
    dist when dist > 100 ->  x=(x1-x2)*100/:math.pow(dist,2)
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