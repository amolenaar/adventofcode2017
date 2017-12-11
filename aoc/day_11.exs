defmodule Day11Test do
  use ExUnit.Case

  def instructions do
    File.read!("aoc/day_11_input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_atom/1)
  end

  for {{a, b}, v} <- %{{:n, :s} => nil,
                       {:nw, :se} => nil,
                       {:ne, :sw} => nil,
                       {:n, :se} => :ne,
                       {:n, :sw} => :nw,
                       {:s, :ne} => :se,
                       {:s, :nw} => :sw,
                       {:se, :sw} => :s,
                       {:ne, :nw} => :n} do
    case v do
      nil ->
        def distance(%{unquote(a) => a, unquote(b) => b} = map) when a > 0 and b > 0,
          do: distance(%{map | unquote(a) => a - 1, unquote(b) => b - 1})
      c ->
        def distance(%{unquote(a) => a, unquote(b) => b, unquote(c) => c} = maps) when a > 0 and b > 0,
          do: distance(%{maps | unquote(a) => a - 1, unquote(b) => b - 1, unquote(c) => c + 1})
    end
  end

  def distance(map) when is_map(map),
    do: map
    |> Map.values
    |> Enum.sum

  def distance(directions) when is_list(directions),
    do: directions
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.into(%{})
    |> distance()

  test "day 11 part 1" do
    assert instructions()
    |> distance() == 764
  end

  test "day 11 part 2" do
    {_dirs, max_dist} = instructions()
    |> Enum.reduce({[], 0},
       fn direction, {dirs, max_dist} ->
         { [ direction | dirs ], max(max_dist, distance([ direction | dirs ])) }
       end)
    assert max_dist == 1532
  end

end
