defmodule Day25Test do
  use ExUnit.Case

  # Begin in state A.
  @begin_state :a
  # Perform a diagnostic checksum after 12172063 steps.
  @steps 12172063


  def cycle(state, val) do
    case {state, val} do
      # In state A:
      #   If the current value is 0:
      #     - Write the value 1.
      #     - Move one slot to the right.
      #     - Continue with state B.
      {:a, 0} -> {1, :right, :b}
      #   If the current value is 1:
      #     - Write the value 0.
      #     - Move one slot to the left.
      #     - Continue with state C.
      {:a, 1} -> {0, :left, :c}

      # In state B:
      #   If the current value is 0:
      #     - Write the value 1.
      #     - Move one slot to the left.
      #     - Continue with state A.
      {:b, 0} -> {1, :left, :a}
      #   If the current value is 1:
      #     - Write the value 1.
      #     - Move one slot to the left.
      #     - Continue with state D.
      {:b, 1} -> {1, :left, :d}

      # In state C:
      #   If the current value is 0:
      #     - Write the value 1.
      #     - Move one slot to the right.
      #     - Continue with state D.
      {:c, 0} -> {1, :right, :d}
      #   If the current value is 1:
      #     - Write the value 0.
      #     - Move one slot to the right.
      #     - Continue with state C.
      {:c, 1} -> {0, :right, :c}

      # In state D:
      #   If the current value is 0:
      #     - Write the value 0.
      #     - Move one slot to the left.
      #     - Continue with state B.
      {:d, 0} -> {0, :left, :b}
      #   If the current value is 1:
      #     - Write the value 0.
      #     - Move one slot to the right.
      #     - Continue with state E.
      {:d, 1} -> {0, :right, :e}

      # In state E:
      #   If the current value is 0:
      #     - Write the value 1.
      #     - Move one slot to the right.
      #     - Continue with state C.
      {:e, 0} -> {1, :right, :c}
      #   If the current value is 1:
      #     - Write the value 1.
      #     - Move one slot to the left.
      #     - Continue with state F.
      {:e, 1} -> {1, :left, :f}

      # In state F:
      #   If the current value is 0:
      #     - Write the value 1.
      #     - Move one slot to the left.
      #     - Continue with state E.
      {:f, 0} -> {1, :left, :e}
      #   If the current value is 1:
      #     - Write the value 1.
      #     - Move one slot to the right.
      #     - Continue with state A.
      {:f, 1} -> {1, :right, :a}
    end
  end

  def move(pos, :left),  do: pos - 1
  def move(pos, :right), do: pos + 1

  def run(state, count), do: run(state, 0, %{}, count)

  def run(_state, _pos, tape, count) when count == 0, do: tape
  def run(state, pos, tape, count) do
    {new_val, dir, new_state} = cycle(state, Map.get(tape, pos, 0))
    new_tape = Map.put(tape, pos, new_val)
    run(new_state, move(pos, dir), new_tape, count - 1)
  end

  def checksum(tape), do: tape |> Map.values |> Enum.sum

  test "day 25 part 1" do
    assert run(@begin_state, @steps) |> checksum == 2474
  end

end
