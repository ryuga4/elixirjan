defmodule HelloPhoenix.Wall do
  @moduledoc false
  defstruct a: :non,
            b: :non,
            c: :non
  @doc """
    Takes point and a wall, and returns distance between them
  """
  def distance([x,y],%HelloPhoenix.Wall{a: a,b: b,c: c}) do
    abs(a*x+b*y+c)/:math.sqrt(a*a+b*b)
  end

  @doc """
      Takes point and a wall, and returns distance between them
    """
  def crossing_point(%HelloPhoenix.Wall{a: a1,b: b1,c: c1},%HelloPhoenix.Wall{a: a2,b: b2,c: c2}) do
    cond do
      a1*b2 == a2*b1 -> raise "Lines will never cross with [a1,b1]=[#{a1},#{b1}] and [a2,b2]=[#{a2},#{b2}]"
      a1==0 -> y=-c1/b1
               x=-(c2+b2*y)/a2
               [x,y]
      b1==0 -> x=-c1/a1
               y=-(c2+a2*x)/b2
               #IO.puts("a2: #{a2}, b2: #{b2}, c2: #{c2}, x: #{x}, y: #{y}")
               #IO.inspect(y)
               [x,y]
      true -> scale = -a2/a1
              y=-(c1*scale+c2)/(b1*scale+b2)
              x=-(b1*y+c1)/a1

              [x,y]
    end
  end

  def closest_point([x,y],%HelloPhoenix.Wall{a: a1,b: b1}=wall1) do
   #IO.puts("a1: #{a1}, b1: #{b1}, x: #{x}, y: #{y}")
   crossing_point(wall1,%HelloPhoenix.Wall{a: b1,b: -a1,c: -(b1*x-a1*y)})
end
  def points(walls) do
    cond do
      Enum.count(walls)<3 -> raise "You need at least 3 walls, #{inspect(walls)} is not enought"
      true -> points2(walls++[hd(walls)])
    end
  end
  defp points2([]), do: []
  defp points2([_]), do: []
  defp points2([wall1,wall2|_]=walls), do: [crossing_point(wall1,wall2)| (points2(tl(walls)))]


  def walls() do
    wall1=%HelloPhoenix.Wall{a: 1,b: 0,c: 0}
    wall2=%HelloPhoenix.Wall{a: 0,b: 1,c: 0}
    wall3=%HelloPhoenix.Wall{a: 1,b: 0,c: -1000}
    wall4=%HelloPhoenix.Wall{a: 0,b: 1,c: -700}
    [wall1,wall2,wall3,wall4]
  end

end