defmodule Day17Test do
  use ExUnit.Case

  @input 343

  def spin(vortex, offset, _steps, count) when count > 2017 do
    vortex |> Enum.at(offset + 1)
  end

  def spin(vortex, offset, steps, count) do
    new_offset = Integer.mod(offset + steps, count) + 1
    {first, second} = vortex |> Enum.split(new_offset)
    new_vortex = first ++ [count | second]
    spin(new_vortex, new_offset, steps, count + 1)
  end

  test "day 17 part 1" do
    assert spin([0], 0, @input, 1) == 1914
  end


  def spin_fast(vortex, _offset, _steps, count) when count > 50_000_000 do
    vortex
  end

  def spin_fast(vortex, offset, steps, count) do
    new_offset = Integer.mod(offset + steps, count) + 1
    new_vortex = if new_offset == 1 do
      count
    else
      vortex
    end
    spin_fast(vortex, new_offset, steps, count + 1)
  end

  @tag timeout: 600_000_000
  test "day 17 part 2" do
    assert spin_fast(0, 0, @input, 1) == 41797835
  end
end
