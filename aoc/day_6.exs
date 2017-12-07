defmodule Day6Test do
  use ExUnit.Case

  @data "4	1	15	12	0	9	9	5	5	8	7	3	14	5	12	3"

  def input() do
    @data
    |> String.split("\t")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.into(%{}, fn {v, i} -> {i, v} end)
  end

  def find_bank_index(banks) do
    {index, _max} = banks |> Enum.reduce(fn {i, v}=a, {j, max}=b -> if v > max or (v == max and i < j), do: a, else: b end)
    index
  end

  def redistribute(banks, index) do
    val = Map.get(banks, index)
    b = Map.put(banks, index, 0)
    redistribute(b, index + 1, val)
  end

  def redistribute(banks, _index, 0) do
    banks
  end

  def redistribute(banks, index, val) do
    case Map.get(banks, index) do
      nil -> redistribute(banks, 0, val)
      v->
        b = Map.put(banks, index, v + 1)
        redistribute(b, index + 1, val - 1)
      end
  end

  def solve(banks, seen) do
    index = find_bank_index(banks)
    new_distribution = redistribute(banks, index)
    if MapSet.member?(seen, new_distribution) do
      {new_distribution, MapSet.size(seen) + 1} # One for this iteration
    else
      solve(new_distribution, MapSet.put(seen, new_distribution))
    end
  end

  test "day 6 part 1" do
    {_, solution} = solve(input(), MapSet.new)
    assert solution == 6681
  end

  test "day 6 part 2" do
    {distribution, _} = solve(input(), MapSet.new)
    seen_set = MapSet.new
    MapSet.put(seen_set, distribution)

    {_, solution} = solve(distribution, seen_set)
    assert solution - 1 == 0
  end

end
