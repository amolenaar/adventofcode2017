defmodule Day22Test do
  use ExUnit.Case

  def load_grid do
    {:ok, lines} = File.open("aoc/day_22_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.trim/1) |> Enum.map(&String.to_charlist/1) |> Enum.to_list
    end)
    lines
  end

  def start_pos([row | _grid]=grid) do
    x = div(Enum.count(row), 2)
    y = div(Enum.count(grid), 2)
    {x, y}
  end

  def to_grid_map(grid) do
    for {row, y} <- Enum.with_index(grid),
        {sq, x} <- Enum.with_index(row) do
      {{x, y}, if(sq == ?#, do: :infected, else: :clean)}
    end
    |> Enum.into(%{})
  end

  def turn(:right, :up),    do: :right
  def turn(:left, :up),     do: :left
  def turn(:right, :down),  do: :left
  def turn(:left, :down),   do: :right
  def turn(:right, :right), do: :down
  def turn(:left, :right),  do: :up
  def turn(:right, :left),  do: :up
  def turn(:left, :left),   do: :down

  def move(:up, {x, y}),    do: {x, y - 1}
  def move(:down, {x, y}),  do: {x, y + 1}
  def move(:right, {x, y}), do: {x + 1, y}
  def move(:left, {x, y}),  do: {x - 1, y}

  def current_node(:infected, dir) do
    new_dir = turn(:right, dir)
    {new_dir, :clean}
  end

  def current_node(:clean, dir) do
    new_dir = turn(:left, dir)
    {new_dir, :infected}
  end

  def burst(grid, dir, pos, acc \\ 0, cnt \\ 0)
  def burst(_grid, _dir, _pos, acc, cnt) when cnt >= 10_000, do: acc
  def burst(grid, dir, pos, acc, cnt) do
    {new_dir, sq} = current_node(Map.get(grid, pos, :clean), dir)
    new_grid = Map.put(grid, pos, sq)
    new_pos = move(new_dir, pos)
    burst(new_grid, new_dir, new_pos, if(sq == :infected, do: acc + 1, else: acc), cnt + 1)
  end

  test "day 22 example" do
    grid = ['..#', '#..', '...']
    pos = {1, 1}
    grid_map = to_grid_map(grid)

    assert burst(grid_map, :up, pos) == 5587
  end

  test "day 22 part 1" do
    grid = load_grid()
    pos = start_pos(grid)
    grid_map = to_grid_map(grid)

    assert pos == {12, 12}
    assert burst(grid_map, :up, pos) == 5339
  end

  def current_node2(:clean, dir) do
    new_dir = turn(:left, dir)
    {new_dir, :weakened}
  end

  def current_node2(:weakened, dir) do
    {dir, :infected}
  end

  def current_node2(:infected, dir) do
    new_dir = turn(:right, dir)
    {new_dir, :flagged}
  end

  def current_node2(:flagged, dir) do
    new_dir = case dir do
      :up -> :down
      :down -> :up
      :left -> :right
      :right -> :left
    end
    {new_dir, :clean}
  end

  def burst2(grid, dir, pos, acc \\ 0, cnt \\ 0)
  def burst2(_grid, _dir, _pos, acc, cnt) when cnt >= 10_000_000, do: acc
  def burst2(grid, dir, pos, acc, cnt) do
    {new_dir, sq} = current_node2(Map.get(grid, pos, :clean), dir)
    new_grid = Map.put(grid, pos, sq)
    new_pos = move(new_dir, pos)
    burst2(new_grid, new_dir, new_pos, if(sq == :infected, do: acc + 1, else: acc), cnt + 1)
  end

  test "day 22 part 2" do
    grid = load_grid()
    pos = start_pos(grid)
    grid_map = to_grid_map(grid)

    assert pos == {12, 12}
    assert burst2(grid_map, :up, pos) == 2512380
  end

end
