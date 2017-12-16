defmodule Day16Test do
  use ExUnit.Case

  @one_billion 1_000_000_000

  def moves do
    {:ok, input} = File.read("aoc/day_16_input.txt")
    input |> String.split(",") |> Enum.map(fn
      "s" <> n -> {:s, String.to_integer(n)}
      "x" <> pair -> String.split(pair, "/") |> Enum.map(&String.to_integer/1) |> (fn [m, n] -> {:x, m, n} end).()
      "p" <> pair -> String.split(pair, "/") |> Enum.map(&String.to_atom/1) |> (fn [a, b] -> {:p, a, b} end).()
    end)
  end

  def dance([], programs), do: programs

  def dance([{:s, n} | moves], programs) do
    {front, back} = Enum.split(programs, -n)
    dance(moves, back ++ front)
  end

  def dance([{:x, m, n} | moves], programs) do
    [{part1, pm}, {part2, pn}, part3] = programs |> Enum.with_index |> Enum.chunk_while([],
      fn
        {p, i}, acc when i == m or i == n -> {:cont, {Enum.reverse(acc), p}, []}
        {p, _i}, acc -> {:cont, [p | acc]}
      end,
      fn acc -> {:cont, Enum.reverse(acc), []} end)
    dance(moves, part1 ++ [pn | part2] ++ [pm | part3])
  end

  def dance([{:p, a, b} | moves], programs) do
    [{part1, pa}, {part2, pb}, part3] = programs |> Enum.chunk_while([],
    fn
      p, acc when p == a or p == b -> {:cont, {Enum.reverse(acc), p}, []}
      p, acc -> {:cont, [p | acc]}
    end,
    fn acc -> {:cont, Enum.reverse(acc), []} end)
    dance(moves, part1 ++ [pb | part2] ++ [pa | part3])
  end

  test "day 16 example" do
    programs = Range.new(?a, ?e) |> Enum.to_list
    moves = [{:s, 1}, {:x, 3, 4}, {:p, ?e, ?b}]
    assert dance(moves, programs) == 'baedc'
  end

  test "day 16 part 1" do
    programs = Range.new(?a, ?p) |> Enum.map(&List.to_string([&1])) |> Enum.map(&String.to_atom/1)
    assert dance(moves(), programs) |> Enum.map(&Atom.to_charlist/1) |> List.flatten == 'lbdiomkhgcjanefp'
  end

  def brute_force(line_up, initial, moves, count \\ 1) do
    new_line_up = dance(moves, line_up)
    if new_line_up == initial do
      count
    else
      brute_force new_line_up, initial, moves, count + 1
    end
  end

  def dance_a_while(_moves, programs, 0), do: programs
  def dance_a_while(moves, programs, dances_to_perform),
    do: dance_a_while(moves, dance(moves, programs), dances_to_perform - 1)

  test "day 16 part 2" do
    programs = Range.new(?a, ?p) |> Enum.map(&List.to_string([&1])) |> Enum.map(&String.to_atom/1)

    back_in_initial_line_up = brute_force programs, programs, moves()
    assert back_in_initial_line_up == 56

    dances_to_perform = Integer.mod(@one_billion, back_in_initial_line_up)

    assert dance_a_while(moves(), programs, dances_to_perform) |> Enum.map(&Atom.to_charlist/1) |> List.flatten == 'ejkflpgnamhdcboi'
  end

end
