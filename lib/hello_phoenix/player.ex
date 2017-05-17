defmodule HelloPhoenix.Player do
  @maxspeed 10
  @minspeed 0.01
  @resistance 0.99
  @accleration 0.5
  @turn_speed 0.03
  @pi 3.141592653589793



  defstruct name: "default",
             position: [500,500],
             velocity: [0,0],
             angle: 0
  def move(%HelloPhoenix.Player{position: [a,b], velocity: [a2,b2]}=player) do
    %{player | position: [a+a2,b+b2]}
  end




  def resistance(%HelloPhoenix.Player{velocity: [a,b]}=player) do
    x= case a*@resistance do
      i when abs(i)<@minspeed -> 0
      i            -> i
    end
    y= case b*@resistance do
      i when abs(i)<@minspeed -> 0
      i            -> i
    end
    %{player | velocity: [x,y]}
  end

  def chech_max (%HelloPhoenix.Player{velocity: [a,b]}=player) do
    case :math.sqrt(a*a+b*b) do
      length when length <= @maxspeed -> player
      length when length >  @maxspeed  -> %{player | velocity: [@maxspeed*a/length,@maxspeed*b/length]}
    end
  end

  def forward (%HelloPhoenix.Player{velocity: [a,b], angle: angle}=player) do
    x=@accleration*:math.cos(angle)
    y=@accleration*:math.sin(angle)
    %{player | velocity: [a+x,b+y]}
  end

  def stop(%HelloPhoenix.Player{velocity: [a,b], angle: angle}=player) do
      x=@accleration*:math.cos(angle)*0.5
      y=@accleration*:math.sin(angle)*0.5
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





end