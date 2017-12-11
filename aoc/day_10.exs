defmodule Day10Test do
  use ExUnit.Case
  use Bitwise

  @input [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]

  def hash(data, lengths, skip_size \\ 0, index \\ 0)
  def hash(data, [], _skip_size, index) do
    {second, first} = data |> Enum.split(index)
    first ++ second
  end

  def hash(data, [length | lengths], skip_size, index) do
    {to_hash, rest} = data |> Enum.split(length)
    hashed = to_hash |> Enum.reverse()
    {skipped, hashed_rest} = (rest ++ hashed) |> Enum.split(skip_size)

    data_len = Enum.count(data)
    new_data = hashed_rest ++ skipped
    new_skip_size = Integer.mod(skip_size + 1, data_len)
    new_index = Integer.mod(index + Enum.count(rest) - skip_size, data_len)
    hash(new_data, lengths, new_skip_size, new_index)
  end

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

  def repeat(l, acc, n) when n > 0,
    do: repeat(l, l ++ acc, n - 1)
  def repeat(_l, acc, _n),
    do: acc

  def to_dense_hash(sparse_hash),
    do: sparse_hash
    |> Enum.chunk_every(16)
    |> Enum.map(fn l -> Enum.reduce(l, &Bitwise.bxor/2) end)

  def to_hex_string(dense_hash),
    do: dense_hash
    |> Enum.map(&Integer.to_string(&1, 16))
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.reduce(&(&2 <> &1))
    |> String.downcase

  def knot_hash(data, lengths) do
    all_lengths = repeat(lengths ++ [17, 31, 73, 47, 23], [], 64)
    hash(data, all_lengths)
    |> to_dense_hash
    |> to_hex_string
  end

  test "Day 10 examples" do
    data = Range.new(0, 255) |> Enum.to_list

    assert knot_hash(data, '') == "a2582a3a0e66e6e86e3812dcb672a272"
    assert knot_hash(data, 'AoC 2017') == "33efeb34ea91902bb2f59c9920caa6cd"
    assert knot_hash(data, '1,2,3') == "3efbe78a8d82f29979031a4aa0b16a9d"
    assert knot_hash(data, '1,2,4') == "63960835bcdc130f0b66d7ff4f6a5a8e"
  end

  test "Day 10 part 2" do
    data = Range.new(0, 255) |> Enum.to_list
    lengths = '83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100'

    result= knot_hash(data, lengths)

    assert result == "d9a7de4a809c56bf3a9465cb84392c8e"
  end
end
