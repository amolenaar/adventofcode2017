defmodule KnotHash do
  use Bitwise

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

  defp repeat(l, acc, n) when n > 0,
    do: repeat(l, l ++ acc, n - 1)
  defp repeat(_l, acc, _n),
    do: acc

  defp to_dense_hash(sparse_hash),
    do: sparse_hash
    |> Enum.chunk_every(16)
    |> Enum.map(fn l -> Enum.reduce(l, &Bitwise.bxor/2) end)

  def to_hex_string(dense_hash),
    do: dense_hash
    |> Enum.map(&Integer.to_string(&1, 16))
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.reduce(&(&2 <> &1))
    |> String.downcase

  def to_bin_string(dense_hash),
    do: dense_hash
    |> Enum.map(&Integer.to_string(&1, 2))
    |> Enum.map(&String.pad_leading(&1, 8, "0"))
    |> Enum.reduce(&(&2 <> &1))

  def knot_hash(lengths) do
    data = Range.new(0, 255) |> Enum.to_list
    all_lengths = repeat(lengths ++ [17, 31, 73, 47, 23], [], 64)
    hash(data, all_lengths)
    |> to_dense_hash
  end

end