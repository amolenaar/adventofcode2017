defmodule Day15Test do
  use ExUnit.Case
  use Bitwise

  @factor_a 16807
  @factor_b 48271
  @generator_a_start 289
  @generator_b_start 629

  def generator(input, factor) do
    Stream.unfold(input, fn acc ->
      n = Integer.mod(acc * factor, 2147483647)
      {n, n}
    end)
  end

  def judge({a, b}) do
    (a &&& 0xffff) == (b &&& 0xffff)
  end

  test "day 15 example" do
    assert generator(65, @factor_a) |> Enum.take(5) == [1092455, 1181022009, 245556042, 1744312007, 1352636452]
    assert generator(8921, @factor_b) |> Enum.take(5) == [430625591, 1233683848, 1431495498, 137874439, 285222916]

    assert Stream.zip(generator(65, @factor_a), generator(8921, @factor_b))
      |> Stream.take(40_000_000)
      |> Stream.filter(&judge/1)
      |> Enum.count == 588
  end

  test "day 15 part 1" do
    assert Stream.zip(generator(@generator_a_start, @factor_a), generator(@generator_b_start, @factor_b))
      |> Stream.take(40_000_000)
      |> Stream.filter(&judge/1)
      |> Enum.count == 638
  end

  test "day 15 part 2" do
    assert Stream.zip(generator(@generator_a_start, @factor_a) |> Stream.filter(fn a -> Integer.mod(a, 4) == 0 end),
                      generator(@generator_b_start, @factor_b) |> Stream.filter(fn a -> Integer.mod(a, 8) == 0 end))
      |> Stream.take(5_000_000)
      |> Stream.filter(&judge/1)
      |> Enum.count == 343
  end

end
