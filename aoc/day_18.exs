defmodule Day18Test do
  use ExUnit.Case

  import Integer, only: [mod: 2]

  def instructions do
    {:ok, lines} = File.open("aoc/day_18_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line([oper, reg]) do
    {String.to_atom(oper), reg}
  end

  def parse_line([oper, reg, val]) do
    v = case Integer.parse(val) do
      {i, ""} -> i
      :error -> val
    end
    {String.to_atom(oper), reg, v}
  end

  def run({:snd, val}, regs)       when is_integer(val), do: Map.put(regs, :snd, val)
  def run({:rcv, val}, regs)       when is_integer(val) and val != 0, do: {:rcv, Map.get(regs, :snd)}
  def run({:rcv, val}, regs)       when is_integer(val), do: regs
  def run({:set, reg, val}, regs)  when is_integer(val), do: Map.put(regs, reg, val)
  def run({:add, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &(&1 + val))
  def run({:mul, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &(&1 * val))
  def run({:mod, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &mod(&1, val))
  def run({:jgz, reg, val}, _regs) when is_integer(reg) and is_integer(val) and reg > 0, do: {:jump, val}
  def run({:jgz, reg, val}, regs)  when is_integer(reg) and is_integer(val), do: regs
  def run({:jgz, reg, val}, regs)  when is_integer(val), do: run({:jgz, Map.get(regs, reg, 0), val}, regs)

  def run({oper, val}, regs), do: run({oper, Map.get(regs, val, 0)}, regs)
  def run({oper, reg, val}, regs), do: run({oper, reg, Map.get(regs, val, 0)}, regs)

  def run_code(instructions), do: run_code(instructions, instructions, %{})

  def run_code([instr | rest], all_instr, regs) do
    case run(instr, regs) do
      {:rcv, val} -> val
      {:jump, val} ->
        offset = -(Enum.count(rest) + 1 - val)
        run_code(all_instr |> Enum.take(offset), all_instr, regs)
      regs -> run_code(rest, all_instr, regs)
    end
  end

  test "day 18 part 1" do
    assert run_code(instructions()) == 9423
  end

end
