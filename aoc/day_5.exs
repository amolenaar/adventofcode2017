defmodule Day5Test do
  use ExUnit.Case, async: true

  # Okay, this must be the most inefficient algorithm

  def instructions do
    {:ok, lines} = File.open("aoc/day_5_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.trim_trailing/1) |> Enum.map(&String.to_integer/1) |> Enum.to_list
    end)
    lines
  end

  def jump(instr, index \\ 0, count \\ 0) do
    val = Enum.at(instr, index)
    case val do
      nil -> count
      val -> jump(List.replace_at(instr, index, val + 1), index + val, count + 1)
    end
  end

  test "day 5 part 1" do
    count = instructions()
    |> jump()

    assert count == 359348
  end

  def jump2(instr, index \\ 0, count \\ 0) do
    val = Enum.at(instr, index)
    case val do
      nil -> count
      val ->
        newval = if val >= 3 do val - 1 else val + 1 end
        jump2(List.replace_at(instr, index, newval), index + val, count + 1)
    end
  end

  @tag timeout: 60_000_000
  test "day 5 part 2" do
    count = instructions()
    |> jump2()

    assert count == 27_688_760
  end

end
