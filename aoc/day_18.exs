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
    {String.to_atom(oper), parse_val(reg), parse_val(val)}
  end

  def parse_val(val) do
    case Integer.parse(val) do
      {i, ""} -> i
      :error -> val
    end
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


  def run2({:snd, val}, regs) when is_integer(val) do
    send(Map.get(regs, :other), {:msg, val})
    if Map.get(regs, :counter) do
      send(Map.get(regs, :counter), {:inc, 1})
    end
    regs
  end

  def run2({:rcv, reg}, regs) do
    receive do
      {:msg, val} -> Map.put(regs, reg, val)
    after
      200 -> :deadlock
    end
  end

  def run2({:set, reg, val}, regs)  when is_integer(val), do: Map.put(regs, reg, val)
  def run2({:add, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &(&1 + val))
  def run2({:mul, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &(&1 * val))
  def run2({:mod, reg, val}, regs)  when is_integer(val), do: Map.update(regs, reg, 0, &mod(&1, val))
  def run2({:jgz, reg, val}, _regs) when is_integer(reg) and is_integer(val) and reg > 0, do: {:jump, val}
  def run2({:jgz, reg, val}, regs)  when is_integer(reg) and is_integer(val), do: regs
  def run2({:jgz, reg, val}, regs)  when is_integer(val), do: run2({:jgz, Map.get(regs, reg, 0), val}, regs)

  def run2({oper, val}, regs), do: run2({oper, Map.get(regs, val, 0)}, regs)
  def run2({oper, reg, val}, regs), do: run2({oper, reg, Map.get(regs, val, 0)}, regs)

  def run_code2(instructions, init),
    do: run_code2(instructions, instructions, init)

  def run_code2([instr | rest], all_instr, regs) do
    case run2(instr, regs) do
      :deadlock -> :ok
      {:jump, val} ->
        offset = -(Enum.count(rest) + 1 - val)
        run_code2(all_instr |> Enum.take(offset), all_instr, regs)
      regs when is_map(regs) -> run_code2(rest, all_instr, regs)
    end
  end

  def listen(count \\ 0) do
    receive do
      {:inc, val} -> listen(count + val)
    after
      1000 -> count
    end
  end

  test "day 18 part 2" do
    instr = instructions()
    Process.register(spawn_link(__MODULE__, :run_code2, [instr, %{"p" => 0, :other => :process1}]), :process0)
    Process.register(spawn_link(__MODULE__, :run_code2, [instr, %{"p" => 1, :other => :process0, :counter => self()}]), :process1)

    assert listen() == 7620
  end
end
