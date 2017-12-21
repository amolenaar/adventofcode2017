defmodule Day19Test do
  use ExUnit.Case

  def load_maze do
    {:ok, lines} = File.open("aoc/day_19_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.to_charlist/1) |> Enum.to_list
    end)
    lines
  end

  def find_starting_pos([row | _rows]),
    do: row |> Enum.with_index |> Enum.find(fn {c, _i} -> c == ?| end) |> (fn {_c, i} -> {i, 0} end).()

  def tile({x, y}, maze) do
    with {:ok, row} <-  maze |> Enum.fetch(y),
         {:ok, tile} <- row |> Enum.fetch(x)
    do
      tile
    end
  end

  def corner?(pos, maze), do: tile(pos, maze) == ?+

  def move(_dir, {x, y}=pos) when x < 0 or y < 0, do: raise "Moving of the chart: #{inspect pos}"
  def move(:up, {x, y}), do: {x, y - 1}
  def move(:down, {x, y}), do: {x, y + 1}
  def move(:left, {x, y}), do: {x - 1, y}
  def move(:right, {x, y}), do: {x + 1, y}
  def move(:finish, pos), do: pos

  def turn(dir1, dir2, pos, maze) do
    cond do
      tile(move(dir1, pos), maze) != 32 -> dir1
      # tile(move(dir1, pos), maze) == ?| -> dir1
      tile(move(dir2, pos), maze) != 32 -> dir2
      # tile(move(dir2, pos), maze) == ?| -> dir2
      true -> raise "Could not move #{dir1} nor #{dir2} from position #{inspect pos} ('#{inspect tile(pos, maze)}')"
    end
  end

  def turn(:up, pos, maze), do: turn(:left, :right, pos, maze)
  def turn(:down, pos, maze), do: turn(:left, :right, pos, maze)
  def turn(:left, pos, maze), do: turn(:up, :down, pos, maze)
  def turn(:right, pos, maze), do: turn(:up, :down, pos, maze)

  def follow_path(_dir, pos, _maze, acc) when length(acc) > 40_000, do: raise "Running the maze for to long #{acc |> List.to_string}"
  def follow_path(:finish, pos, _maze, [_ | acc]),
    do: { acc
    |> Enum.count, acc
    |> Enum.filter(fn c -> c != ?| and c != ?- and c != ?+ end)
    |> Enum.reverse() }

  def follow_path(_dir, {x, y}, _maze, acc) when x < 0 or y < 0,
    do: acc
    |> Enum.filter(fn c -> c != ?| and c != ?- and c != ?+ end)
    |> Enum.reverse()

  def follow_path(dir, pos, maze, acc) do
    new_dir = cond do
      corner?(pos, maze) -> turn(dir, pos, maze)
      tile(pos, maze) == 32 -> :finish
      true -> dir
    end
    follow_path(new_dir, move(new_dir, pos), maze, [tile(pos, maze) | acc])
  end

  test "day 19 example" do
    maze = [
      '    |          ',
      '    |  +--+    ',
      '    A  |  C    ',
      'F---|----E|--+ ',
      '    |  |  |  D ',
      '    +B-+  +--+ ']
    starting_pos = find_starting_pos(maze)

    assert starting_pos == {4, 0}

    assert follow_path(:down, starting_pos, maze, [])  == 'ABCDEF'
  end

  test "day 19 part 1" do
    maze = load_maze()
    starting_pos = find_starting_pos(maze)

    assert starting_pos == {163, 0}

    assert follow_path(:down, starting_pos, maze, []) == {17736, 'PVBSCMEQHY'}
  end

end
