defmodule Day24Test do
  use ExUnit.Case

  def read_components() do
    {:ok, lines} = File.open("aoc/day_24_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&parse_line/1) |> Enum.into(MapSet.new)
    end)
    lines
  end

  def parse_line(line) do
    line
    |> String.trim
    |> String.split("/")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def find_components(components, pins), do: components |> Enum.filter(fn {a, b} -> a == pins or b == pins end)

  def other_end({pins, b}, pins), do: b
  def other_end({a, pins}, pins), do: a

  def find_bridges(components, pins) when is_integer(pins),
    do: find_bridges(components, pins, find_components(components, pins), [])

  def find_bridges(_components, _pins, [], bridge_so_far),
    do: [bridge_so_far]
  def find_bridges(components, pins, [component | matching_components], bridge_so_far) do
    new_comps = MapSet.delete(components, component)
    new_pins = other_end(component, pins)
    new_matching = find_components(new_comps, new_pins)
    depth_strength = find_bridges(new_comps, new_pins, new_matching, [component | bridge_so_far])

    breath_strength = find_bridges(components, pins, matching_components, bridge_so_far)

    depth_strength ++ breath_strength
  end

  test "day 24 part 1 and 2" do
    components = read_components()

    all_bridges = find_bridges(components, 0)
    assert all_bridges
    |> Enum.map(fn bridge -> bridge |> Enum.reduce(0, fn {a, b}, cnt -> a + b + cnt end) end)
    |> Enum.reduce(&max/2)== 1906

    assert all_bridges
    |> Enum.reduce([[]], fn
      bridge1, [b2 | _]=bridge2 when length(bridge1) == length(b2) ->
        [bridge1 | bridge2]
      bridge1, [b2 | _] when length(bridge1) > length(b2) ->
        [bridge1]
      _, acc -> acc
    end)
    |> Enum.map(&Enum.reduce(&1, 0, fn {a, b}, cnt -> a + b + cnt end))
    |> Enum.reduce(&max/2) == 1824
  end

end
