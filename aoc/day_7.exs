defmodule Day7Test do
  use ExUnit.Case

  def instructions do
    {:ok, lines} = File.open("aoc/day_7_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.into(%{})
    end)
    lines
  end

  def parse_line([name, weight]) do
    {name |> String.trim,
     parse_weight(weight)}
  end

  def parse_line([name, weight, "->" | holding]) do
    {name |> String.trim,
     {parse_weight(weight),
      holding |> Enum.map(fn n -> String.trim_trailing(n, ",") end)}}
  end

  def parse_weight(weight) do
    weight |> String.trim_leading("(") |> String.trim_trailing(")") |> String.to_integer
  end

  def find_at_the_bottom(instr) do
    names = instr
      |> Map.keys()
      |> Enum.into(MapSet.new())

    names_above = instr |> Enum.map(fn
        {_name, {_weight, holding}} -> holding
        {_name, _weight} -> []
      end)
      |> List.flatten()
      |> Enum.into(MapSet.new())

    MapSet.difference(names, names_above) |> MapSet.to_list |> Enum.at(0)
  end

  test "day 7 part 1" do
    at_the_bottom = instructions()
      |> find_at_the_bottom()

    assert at_the_bottom == "ahnofa"
  end


  def required_weight(structure) do
    at_the_bottom = find_at_the_bottom(structure)

    required_weight(structure, at_the_bottom)
  end

  def required_weight(structure, program) do
    case Map.get(structure, program) do
      {weight, holding} ->
        weights = for h <- holding, do: required_weight(structure, h)
        cond do
          unbalanced = unbalanced?(weights) ->
            unbalanced
          same?(weights) ->
            weight + (weights |> Enum.sum())
          true ->
            unbalanced = rebalance(weights, program_weights(structure, holding))
            {:unbalanced, unbalanced}
        end
      weight when is_integer(weight) ->
        weight
    end
  end

  def same?(items), do: MapSet.new(items) |> MapSet.size() == 1

  def rebalance(weights, child_weights) do
    first_weight = List.first(child_weights)
    weight_pairs = weights
    |> Enum.zip(child_weights)
    |> Enum.chunk_by(fn {_w, cw} -> cw == first_weight end)

    {odd_child_weight, odd_weight} = weight_pairs
    |> Enum.filter(fn w -> Enum.count(w) > 1 end) |> Enum.at(0) |> Enum.at(0)

    {other_child_weight, _} = weight_pairs
    |> Enum.filter(fn w -> Enum.count(w) <= 1 end) |> Enum.at(0) |> Enum.at(0)

    odd_weight + other_child_weight - odd_child_weight
  end

  def program_weights(structure, programs) do
    for p <- programs do
      case Map.get(structure, p) do
        {w, _h} -> w
        w -> w
      end
    end
  end

  def unbalanced?(weights) do
    weights
    |> Enum.reduce(false, fn
      ({:unbalanced, _}=w, _acc) -> w
      (_, acc) -> acc
    end)
  end

  test "day 7 part 2" do
    {:unbalanced, weight} = instructions()
    |> required_weight()

    assert weight == 802
 end

end
