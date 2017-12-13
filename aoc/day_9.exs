defmodule Day9Test do
  use ExUnit.Case

  setup do
    Agent.start_link(fn -> 0 end, name: :garbage_counter)
    :ok
  end

  def instructions do
    File.read!("aoc/day_9_input.txt") |> String.to_charlist
  end

  def parse(stream, acc \\ [])

  def parse([], acc),
    do: Enum.at(acc, 0)

  def parse([?!, _char | stream], acc),
    do: parse(stream, acc)

  def parse([?{ | stream], acc) do
    {s, a} = parse(stream, [])
    parse(s, [a | acc])
  end

  def parse([?} | stream], acc) do
    {stream, acc}
  end

  def parse([?< | stream], acc) do
    s = parse_garbage(stream)
    parse(s, acc)
  end

  def parse([_char | stream], acc),
    do: parse(stream, acc)

  def parse_garbage([?!, _char | stream]),
    do: parse_garbage(stream)

  def parse_garbage([?> | stream]),
    do: stream

  def parse_garbage([_char | stream]) do
    increment_garbage_count()
    parse_garbage(stream)
  end

  def increment_garbage_count() do
    Agent.update(:garbage_counter, &(&1 + 1))
  end

  def score(lists, v \\ 1)

  def score([], v) do
    v
  end

  def score(rest, v) do
    a = rest |> Enum.map(&score(&1, v + 1)) |> Enum.sum()
    v + a
  end

  # Alternative to the function above:

  # def score([rest], v) do
  #   a = score(rest, v + 1)
  #   v + a
  # end

  # def score([rest | other], v) do
  #   a = score(rest, v + 1)
  #   b = score(other, v)
  #   a + b
  # end

  test "day 9 part 1 and 2" do
    assert parse('{}') |> score() == 1
    assert parse('{{{}}}') |> score() == 6
    assert parse('{{{},{},{{}}}}') |> score() == 16

    assert instructions() |> parse() |> score() == 7640

    assert Agent.get(:garbage_counter, &(&1)) == 4368
  end

end
