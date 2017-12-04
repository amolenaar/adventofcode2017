defmodule Day4Test do
  use ExUnit.Case

  def passphrases do
    {:ok, lines} = File.open("aoc/day_4_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.to_list
    end)
    lines
  end

  def is_valid(phrase),
    do: phrase |> Enum.count == phrase |> Enum.uniq |> Enum.count

  test "Day 4 part 1" do
    phrases = passphrases()
    |> Enum.filter(&is_valid/1)

    assert phrases |> Enum.count == 477
  end

  def flat_sort(phrase) do
    phrase
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.sort/1)
  end

  test "Day 4 part 2" do
    phrases = passphrases()
    |> Enum.map(&flat_sort/1)
    |> Enum.filter(&is_valid/1)

    assert phrases |> Enum.count == 167
  end

end

#vim:sw=4:et:ai
