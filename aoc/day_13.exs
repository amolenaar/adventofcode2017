defmodule Day13Test do
  use ExUnit.Case

  import Integer

  def instructions do
    {:ok, lines} = File.open("aoc/day_13_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split(&1, ":")) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line([depth, range]),
    do: {depth |> String.trim |> String.to_integer,
     range |> String.trim |> String.to_integer}

  def severity({depth, range}, delay) do
    picosecond = depth + delay
    case mod(picosecond, range * 2 - 2) do
      0 -> depth * range
      _ -> :passed
    end
  end

  def severity_of_trip(layers, delay \\ 0),
    do: layers
    |> Enum.map(&severity(&1, delay))
    |> Enum.reduce(fn :passed, acc -> acc; sev, :passed -> sev; sev, acc -> sev + acc end)

  test "day 13 part 1" do
    layers = instructions()

    assert severity_of_trip(layers) == 2688
  end

  test "day 13 part 2" do
    layers = instructions()

    {:ok, {delay, :passed}} =
      Stream.unfold(10, &({&1, &1 + 1}))
      |> Stream.map(fn delay -> {delay, severity_of_trip(layers, delay)} end)
      |> Stream.filter(fn {_delay, sev} -> sev == :passed end)
      |> Enum.fetch(0)

    assert delay == 3876272
  end
end
