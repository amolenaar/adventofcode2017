defmodule Day12Test do
  use ExUnit.Case, async: false

  def instructions do
    {:ok, lines} = File.open("aoc/day_12_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line([process, "<->" | others]) do
    {process |> String.to_atom,
     others |> Enum.map(&String.trim_trailing(&1, ",")) |> Enum.map(&String.to_atom/1)}
  end

  def launch(ids),
    do: ids |> Enum.map(fn {my_id, chat_to} ->
      Process.register(spawn_link(__MODULE__, :listen, [my_id, chat_to]), my_id)
    end)

  def listen(my_id, chat_to) do
    receive do
      {:hi, originator} ->
        send(originator, {:id, my_id})
        chat_to |> Enum.map(fn p -> Process.send_after(p, {:hi, originator}, 10) end)
        listen(my_id, [])
        msg ->
          IO.puts("Process #{my_id} stopped: #{inspect msg}")
          :stop
    end
  end

  def wait_till_chatting_is_over(ids_seen \\ MapSet.new) do
    receive do
      {:id, id} ->
        wait_till_chatting_is_over(MapSet.put(ids_seen, id))
    after
      200 -> ids_seen
    end
  end

  test "Day 12 part 1" do
    instructions()
    |> launch

    send(:"0", {:hi, self()})

    assert wait_till_chatting_is_over() |> Enum.count == 152
  end

  def find_groups(proc_ids, count) do
    case MapSet.size(proc_ids) do
      0 -> count
      _->
        {:ok, id} = proc_ids |> Enum.fetch(0)
        send(id, {:hi, self()})

        ids_in_group = wait_till_chatting_is_over()

        IO.puts("Found #{ids_in_group |> Enum.count} members in group with id #{id}")

        find_groups(
          MapSet.new(proc_ids)
          |> MapSet.difference(ids_in_group),
          count + 1)
    end
  end

  test "Day 12 part 2" do
    instr = instructions()

    instr |> launch

    ids = instr
    |> Enum.map(fn {my_id, _chat_to} -> my_id end)
    |> Enum.into(MapSet.new)

    assert find_groups(ids, 0) == 186
  end

end
