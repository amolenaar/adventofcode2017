defmodule Day10Test do
  use ExUnit.Case

  import KnotHash

  @input [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]


  def multiply([v1, v2 | _data]) do
    v1 * v2
  end

  test "day 10 example" do
    data = [0, 1, 2, 3, 4]
    lengths = [3, 4, 1, 5]

    assert hash(data, lengths) |> multiply() == 12
  end

  test "day 10 part 1" do
    data = Range.new(0, 255) |> Enum.to_list
    lengths = @input
    assert hash(data, lengths) |> multiply() == 20056
  end


  test "Day 10 examples" do
    assert knot_hash('') |> to_hex_string == "a2582a3a0e66e6e86e3812dcb672a272"
    assert knot_hash('AoC 2017') |> to_hex_string == "33efeb34ea91902bb2f59c9920caa6cd"
    assert knot_hash('1,2,3') |> to_hex_string == "3efbe78a8d82f29979031a4aa0b16a9d"
    assert knot_hash('1,2,4') |> to_hex_string == "63960835bcdc130f0b66d7ff4f6a5a8e"
  end

  test "Day 10 part 2" do
    lengths = '83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100'

    result= knot_hash(lengths) |> to_hex_string

    assert result == "d9a7de4a809c56bf3a9465cb84392c8e"
  end
end
