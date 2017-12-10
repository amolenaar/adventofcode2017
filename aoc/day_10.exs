defmodule Day10Test do
  use ExUnit.Case

  @input [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]

  def hash(data, lengths, skip_size \\ 0, index \\ 0)
  def hash(data, [], _skip_size, index) do
    v1 = Enum.at(data, index)
    v2 = Enum.at(data, index + 1)
    v1 * v2
  end

  def hash(data, [length | lengths], skip_size, index) do
    {to_hash, rest} = data |> Enum.split(length)
    hashed = to_hash |> Enum.reverse()
    {skipped, hashed_rest} = (rest ++ hashed) |> Enum.split(skip_size)

    new_data = hashed_rest ++ skipped
    offset = Integer.mod(index + Enum.count(rest) - skip_size, Enum.count(data))
    hash(new_data, lengths, skip_size + 1, offset)
  end

  test "day 10 example" do
    data = [0, 1, 2, 3, 4]
    lengths = [3, 4, 1, 5]

    assert hash(data, lengths) == 12
  end

  test "day 10 part 1" do
    data = Range.new(0, 255) |> Enum.to_list
    lengths = @input
    assert hash(data, lengths) == 20056
  end

  test "Day 10 part 2" do
  end

end
