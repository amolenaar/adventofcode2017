defmodule Day3Test do
  use ExUnit.Case

  @input 325489

  def find_corners(up_to, incr \\ 1, acc \\ [1])
  # We add two edges, if the first one is already big enough, drop the second
  def find_corners(up_to, _incr, [_v, w | rest]) when w >= up_to,
    do: Enum.reverse([w | rest])
  def find_corners(up_to, _incr, [v | _rest] = acc) when v >= up_to,
    do: Enum.reverse(acc)
  def find_corners(up_to, incr, [v | _rest] = acc),
    do: find_corners(up_to, incr + 1, [v + incr*2, v + incr | acc])

  def to_circles(corner_values, acc \\ [])
  def to_circles([a, _b, _c, d | vals], acc),
    do: to_circles(vals, [{a, d-1} | acc])
  def to_circles([], acc),
    do: Enum.reverse(acc)
  def to_circles(vals, acc),
    do: to_circles([], [{List.first(vals), List.last(vals)} | acc])


  test "day 3 part 1" do

    corners = find_corners(@input)

    ring = corners
    |> Enum.drop(2) # We do not need the starting values in our circles
    |> to_circles
    |> Enum.count

    [a, b] = Enum.take(corners, -2)
    center_of_edge = div(b - a, 2)
    pos_on_edge = abs(@input - a - center_of_edge)

    assert pos_on_edge + ring == 552
  end


  def calc_offsets(_index, [], _offset, offsets),
    do: Enum.reverse(offsets)

  # Corner, take only previous index
  def calc_offsets(index, [index | _rest] = corners, offset, offsets),
    do: calc_offsets(index + 1, corners, offset + 1, [[1, offset + 1] | offsets])

  # Compensate for small rings, without center piece elements
  def calc_offsets(index, [_old_corner, corner | corners], offset, offsets) when corner - 1 == index,
    do: calc_offsets(index + 1, [corner | corners], offset + 1, [[1, 2, offset + 1] |> Enum.uniq | offsets])

  # Before the corner, take only last 2 indices
  def calc_offsets(index, [corner | _rest] = corners, offset, offsets) when corner - 1 == index,
    do: calc_offsets(index + 1, corners, offset + 1, [[1, offset + 1, offset + 2] |> Enum.uniq | offsets])

  # After the corner, add extra [n-2]
  def calc_offsets(index, [corner | corners], offset, offsets) when corner + 1 == index,
    do: calc_offsets(index + 1, corners, offset, [[1, 2, offset, offset + 1] |> Enum.uniq | offsets])

  # Center piece
  def calc_offsets(index, corners, offset, offsets),
    do: calc_offsets(index + 1, corners, offset, [[1, offset, offset + 1, offset + 2] |> Enum.uniq | offsets])

  def sumize_offsets(_offsets, [a |_acc]) when a >= @input,
    do: a

  def sumize_offsets([[0] | offsets], _acc),
    do: sumize_offsets(offsets, [1])

  def sumize_offsets([offset | offsets], acc) do
    val = offset |> Enum.map(fn o -> Enum.at(acc, o - 1) end) |> Enum.sum
    sumize_offsets(offsets, [val | acc])
  end

  test "day 3 part 2" do
    # Find first value > @input
    # by generating @input corners, we should have plenty of data to work with
    corners = find_corners(@input)

    result = calc_offsets(3, corners |> Enum.drop(2), 1, [[1], [0]])
    |> sumize_offsets([])
    
    assert result == 330785
  end

end
# vim:sw=2:et:ai
