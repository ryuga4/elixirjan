defmodule HelloPhoenix.Player do
  @maxspeed 10
  @maxspeed_bomb 50
  @minspeed 0.01
  @resistance 0.96
  @accleration 0.8
  @turn_speed 0.06
  @pi 3.141592653589793
  @width 1000
  @height 700
  @stop 0.5


  defstruct name: "default",
             position: [500,500],
             velocity: [0,0],
             angle: 0,
             max_speed: @maxspeed,
             turning: :none,
             move: :none,
             inc: 0,
             help: 0,
             key: "default",
             bomb: false,
             after_bomb: false
  def move(%HelloPhoenix.Player{position: [a,b], velocity: [a2,b2]}=player) do
    x = case a+a2 do
       sth when sth > @width -> @width
       sth when sth < 0    -> 0
       sth                 -> sth
    end
    y = case b+b2 do
       sth when sth > @height -> @height
       sth when sth < 0    -> 0
       sth                 -> sth
    end
    %{player | position: [x,y]}
  end
  
  
  
  def set_turning(%HelloPhoenix.Player{}=player, turning) do
    %{player | turning: turning}
  end

  def set_move(%HelloPhoenix.Player{}=player, move) do
      %{player | move: move}
  end
  def set_help(%HelloPhoenix.Player{}=player,set) do
      %{player | help: set}
  end

  def resistance(%HelloPhoenix.Player{velocity: [a,b],inc: inc}=player) do
    x= case a*@resistance do
      i when abs(i)<@minspeed -> 0
      i            -> i
    end
    y= case b*@resistance do
      i when abs(i)<@minspeed -> 0
      i            -> i
    end
    %{player | velocity: [x,y], inc: inc+1}
  end

  def chech_max (%HelloPhoenix.Player{velocity: [a,b], max_speed: max_speed}=player) do
    case :math.sqrt(a*a+b*b) do
      length when length <= max_speed -> player
      length when length >  max_speed  -> %{player | velocity: [max_speed*a/length,max_speed*b/length]}
    end
  end
  def check_turning(%HelloPhoenix.Player{turning: :none}=player) do
      player
  end

  def check_turning(%HelloPhoenix.Player{turning: turning}=player) do
    case turning do
      :left -> player |> turn_left()
      :right -> player |> turn_right()
      e -> IO.puts e
    end
  end

  def check_move(%HelloPhoenix.Player{move: :none}=player) do
        player
    end

    def check_move(%HelloPhoenix.Player{move: move}=player) do
      case move do
        :forward -> player |> forward()
        :stop -> player |> stop()
        e -> IO.puts e
      end
    end


  def forward (%HelloPhoenix.Player{velocity: [a,b], angle: angle}=player) do
    x=@accleration*:math.cos(angle)
    y=@accleration*:math.sin(angle)
    %{player | velocity: [a+x,b+y]}
  end

  def stop(%HelloPhoenix.Player{velocity: [a,b], angle: angle}=player) do
      x=@accleration*:math.cos(angle)*@stop
      y=@accleration*:math.sin(angle)*@stop
      %{player | velocity: [a-x,b-y]}
  end

  def turn_right(%HelloPhoenix.Player{angle: angle}=player) do
    pi=@pi*2
    %{player | angle: case angle+@turn_speed do
                            a when a >= pi -> a - pi
                            a when a < pi -> a
                          end}
  end

  def turn_left(%HelloPhoenix.Player{angle: angle}=player) do
    pi=@pi*2
    %{player | angle: case angle-@turn_speed do
                            a when a < 0 -> pi - a
                            a when a >= 0 -> a
                          end}
  end

  def add_bomb(%HelloPhoenix.Player{}=player) do
    %{player | bomb: true, max_speed: @maxspeed_bomb}
  end

  def remove_bomb(%HelloPhoenix.Player{}=player) do
    %{player | bomb: false, after_bomb: true}
  end

  def out_of_range(%HelloPhoenix.Player{}=player) do
      %{player | after_bomb: false, max_speed: @maxspeed}
  end









end
