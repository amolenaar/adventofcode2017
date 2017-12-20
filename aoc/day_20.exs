defmodule Day20Test do
  use ExUnit.Case

  def instructions do
    {:ok, lines} = File.open("aoc/day_20_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.into([])
    end)
    lines
  end

  def parse_line(["p="<> p, "v=" <> v, "a=" <> a]) do
    {parse_coord(p), parse_coord(v), parse_coord(a)}
  end

  def parse_coord("<" <> coord) do
    with {x, restx} <- Integer.parse(coord),
         {y, resty} <- restx |> String.trim(",") |> Integer.parse(),
         {z, _}     <- resty |> String.trim(",") |> Integer.parse() do
      {x, y, z}
    end
  end

  def next_frame(particles) do
    particles
    |> Enum.map(fn {p, {vx, vy, vz}, {ax, ay, az}=a} -> {p, {vx + ax, vy + ay, vz + az}, a} end)
    |> Enum.map(fn {{px, py, pz}, {vx, vy, vz}=v, a} -> {{px + vx, py + vy, pz + vz}, v, a} end)
  end

  def slowest(particles) do
    particles
    |> Enum.map(fn {_p, {x, y, z}, _a} -> abs(x) + abs(y) + abs(z) end)
    |> Enum.with_index()
    |> Enum.reduce(fn
         {da, _ia}, {db, _ib}=b when da > db -> b
         a, _ -> a
       end)
    |> elem(1)
  end

  def run(particles, state \\ %{}, count \\ 10_000)
  def run(_particles, state, 0), do: state
  def run(particles, state, count) do
    run(next_frame(particles),
        Map.update(state, slowest(particles), 1, &(&1 + 1)),
        count - 1)
  end

  test "day 20 part 1" do
    particles = instructions()
    %{376 => 9832} = run(particles)
  end


  def detect_collisions(particles) do
    particles
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {{p, _v, _a}, i}, collisions -> Map.update(collisions, p, [i], &([i | &1])) end)
    |> Map.values
    |> Enum.filter(&(Enum.count(&1) > 1))
    |> List.flatten
    |> Enum.sort(&(&1 >= &2))
  end

  def drop_at(l, i) do
    {_val, rest} = List.pop_at(l, i)
    rest
  end

  def run2(particles, count \\ 10_000)
  def run2(particles, 0), do: particles
  def run2(particles, count) do
    remaining = particles
      |> detect_collisions()
      |> Enum.reduce(particles, &drop_at(&2, &1))
    run2(next_frame(remaining), count - 1)
  end

  test "day 20 part 2" do
    particles = instructions()
    assert run2(particles) |> Enum.count == 574
  end

end
