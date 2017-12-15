defmodule Day14Test do
  use ExUnit.Case

  import KnotHash
  @input "wenycdww"


  def count_ones(data, acc \\ 0)
  def count_ones(<<>>, acc), do: acc
  def count_ones(<<0 :: size(1), rest  :: bitstring>>, acc), do: count_ones(rest, acc)
  def count_ones(<<1 :: size(1), rest  :: bitstring>>, acc), do: count_ones(rest, acc + 1)

  test "bit counter" do
    assert count_ones(<<2>>) == 1
    assert count_ones(<<7>>) == 3
  end

  test "day 14 part 1" do
    squares = for n <- Range.new(0, 127) do
      knot_hash(@input <> "-#{n}" |> String.to_charlist)
      |> IO.iodata_to_binary
      |> count_ones
    end |> Enum.sum

    assert squares == 8226
  end

  def merge_regions(regions, edge), do: merge_regions(regions, edge, [], [])
  def merge_regions([], _edge, to_be_merged, other_regions),
    do: [to_be_merged |> Enum.reduce(&MapSet.union/2) | other_regions]
  def merge_regions([region | regions], edge, to_be_merged, other_regions) do
    if MapSet.member?(region, edge) do
      merge_regions(regions, edge, [region | to_be_merged], other_regions)
    else
      merge_regions(regions, edge, to_be_merged, [region | other_regions])
    end
  end

  def update_region([], e1, e2) do
    # IO.puts "new   #{inspect e1} to #{inspect e2}"
    [MapSet.new([e1, e2])]
  end
  def update_region([region | regions], e1, e2) do
    cond do
      MapSet.member?(region, e1) ->
        [MapSet.put(region, e2) | regions]
        |> merge_regions(e1)
        |> merge_regions(e2)
      MapSet.member?(region, e2) ->
        [MapSet.put(region, e1) | regions]
        |> merge_regions(e1)
        |> merge_regions(e2)
      true ->
        [region | update_region(regions, e1, e2)]
    end
  end

  def group([], regions), do: regions
  def group([{e1, e2} | edges], regions) do
    group(edges, update_region(regions, e1, e2))
  end

  test "day 14 part 2" do
    grid = for n <- Range.new(0, 127) do
      knot_hash(@input <> "-#{n}" |> String.to_charlist)
      |> to_bin_string
      |> String.to_charlist
    end

    grid_map = for {row, y} <- Enum.with_index(grid),
        {sq, x} <- Enum.with_index(row) do
      {{x, y}, sq - ?0}
    end |> Enum.filter(fn {{_x, _y}, s} -> s != 0 end) |> Enum.into(%{})

    edges = for {x, y} <- Map.keys(grid_map) do
      [{{x, y}, {x, y}},
        Map.has_key?(grid_map, {x - 1, y}) && {{x, y}, {x - 1, y}},
        Map.has_key?(grid_map, {x + 1, y}) && {{x, y}, {x + 1, y}},
        Map.has_key?(grid_map, {x, y - 1}) && {{x, y}, {x, y - 1}},
        Map.has_key?(grid_map, {x, y + 1}) && {{x, y}, {x, y + 1}}] |> Enum.filter(&(&1))
    end |> List.flatten

    regions = group(edges, [])

    assert regions |> Enum.count == []
  end

end
