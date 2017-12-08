defmodule Day8Test do
  use ExUnit.Case

  import String

  def instructions do
    {:ok, lines} = File.open("aoc/day_8_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&split/1) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line([reg, oper, value, "if", creg, ccond, cval]) do
    [reg, to_oper(oper), to_integer(value), creg, to_atom(ccond), to_integer(cval)]
  end

  def to_oper("inc"), do: :+
  def to_oper("dec"), do: :-

  def process_instructions(instr) do
    instr |> Enum.reduce({%{}, 0},
      fn [reg, oper, val, creg, ccond, cval], {regs, max_val}=acc ->
        if apply(Kernel, ccond, [Map.get(regs, creg, 0), cval]) do
          new_val = apply(Kernel, oper, [Map.get(regs, reg, 0), val])
          {Map.put(regs, reg, new_val), Enum.max([max_val, new_val])}
        else
          acc
        end
      end)
  end

  test "day 8 part 1 and 2" do
    {regs, intermediate_max_val} = instructions()
    |> process_instructions()

    max_val = regs
    |> Map.values
    |> Enum.max

    assert max_val == 5966
    assert intermediate_max_val == 6347
  end

end
