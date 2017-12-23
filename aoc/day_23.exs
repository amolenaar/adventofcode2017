defmodule Day23Test do
  use ExUnit.Case

  def instructions() do
    {:ok, lines} = File.open("aoc/day_23_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line([oper, reg]) do
    {String.to_atom(oper), reg}
  end

  def parse_line([oper, reg, val]) do
    {String.to_atom(oper), parse_val(reg), parse_val(val)}
  end

  def parse_val(val) do
    case Integer.parse(val) do
      {i, ""} -> i
      :error -> val
    end
  end

  def run({:set, reg, val}, regs)  when is_integer(val), do: Map.put(regs, reg, val)
  def run({:sub, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &(&1 - val))
  def run({:mul, reg, val}, regs)  when is_integer(val), do: {:mul, Map.update(regs, reg, 0, &(&1 * val))}
  def run({:jnz, reg, val}, _regs) when is_integer(reg) and is_integer(val) and reg != 0, do: {:jump, val}
  def run({:jnz, reg, val}, regs)  when is_integer(reg) and is_integer(val), do: regs
  def run({:jnz, reg, val}, regs)  when is_integer(val), do: run({:jnz, Map.get(regs, reg, 0), val}, regs)

  def run({oper, val}, regs), do: run({oper, Map.get(regs, val, 0)}, regs)
  def run({oper, reg, val}, regs), do: run({oper, reg, Map.get(regs, val, 0)}, regs)

  def run_code(instructions), do: run_code(instructions, instructions, %{}, 0)

  def run_code([], _all_instr, _regs, muls), do: muls
  def run_code([instr | rest], all_instr, regs, muls) do
    case run(instr, regs) do
      {:mul, regs} ->
        run_code(rest, all_instr, regs, muls + 1)
      {:jump, val} ->
        offset = -(Enum.count(rest) + 1 - val)
        run_code(all_instr |> Enum.take(offset), all_instr, regs, muls)
      regs -> run_code(rest, all_instr, regs, muls)
    end
  end

  test "day 23 part 1" do
    assert run_code(instructions()) == 3969
  end
end
