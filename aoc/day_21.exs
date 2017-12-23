defmodule Day21Test do
  use ExUnit.Case

  @start ['.#.',
          '..#',
          '###']

  ## Preparation

  def load_rules do
    {:ok, lines} = File.open("aoc/day_21_input.txt", [:read], fn(file) ->
      IO.stream(file, :line) |> Enum.map(&String.split/1) |> Enum.map(&parse_line/1) |> Enum.to_list
    end)
    lines |> List.flatten |> Enum.into(%{})
  end

  def parse_line([input, "=>", output]) do
    in_pat = parse_pattern(input)
    out_pat = parse_pattern(output)
    [{in_pat, out_pat},
     {flip_horizontal(in_pat), out_pat},
     {flip_vertical(in_pat), out_pat},
     {rotate90(in_pat), out_pat},
     {rotate90(in_pat) |> flip_horizontal, out_pat},
     {rotate90(in_pat) |> flip_vertical, out_pat},
     {rotate180(in_pat), out_pat},
     {rotate180(in_pat) |> flip_horizontal, out_pat},
     {rotate180(in_pat) |> flip_vertical, out_pat},
     {rotate270(in_pat), out_pat},
     {rotate270(in_pat) |> flip_horizontal, out_pat},
     {rotate270(in_pat) |> flip_vertical, out_pat}]
  end

  def parse_pattern(pat) do
    pat
    |> String.split("/")
    |> Enum.map(&String.to_charlist/1)
  end

  def zip(list_of_lists), do: Enum.zip(list_of_lists) |> Enum.map(&Tuple.to_list/1)

  def flip_horizontal(s), do: Enum.reverse(s)
  def flip_vertical(s), do: Enum.map(s, &Enum.reverse/1)
  def rotate90(s), do: zip(s) |> Enum.map(&Enum.reverse/1)
  def rotate180(s), do: rotate90(s) |> rotate90
  def rotate270(s), do: rotate180(s) |> rotate90


  def divide([[_a, _b] | _]=square), do: [[square]]
  def divide([[_a, _b, _c] | _]=square), do: [[square]]
  def divide([row | _rest]=square) do
    size = row |> Enum.count
    cond do
      Integer.mod(size, 2) == 0 ->
        divide_every(square, 2)
      Integer.mod(size, 3) == 0 ->
        divide_every(square, 3)
    end
  end

  def divide_every(square, div_by) do
    square
    |> Enum.map(&Enum.chunk_every(&1, div_by))
    |> Enum.chunk_every(div_by)
    |> Enum.map(&zip/1)
  end

  def merge(squares),
    do: squares
    |> Enum.map(fn a -> Enum.reduce(a, fn a, b -> Enum.zip(b, a)
                                                  |> Enum.map(fn {a, b} -> a ++ b end) end)
                end)
    |> Enum.reduce(&(&2 ++ &1))

  def generate_some_art(square, _rules, 0), do: square
  def generate_some_art(square, rules, count) do
    square
    square
    |> divide()
    |> Enum.map(fn row -> Enum.map(row, &Map.get(rules, &1, :error)) end)
    |> merge()
    |> generate_some_art(rules, count - 1)
  end

  def lights_on(art), do: art |> Enum.reduce(&(&2 ++ &1)) |> Enum.filter(&(&1 == ?#)) |> Enum.count

  test "splitting of 2x2 grid" do
    s = ['ab', 'cd']
    o = [[['ab', 'cd']]]
    assert divide(s) == o
  end

  test "splitting of 3x3 grid" do
    s = ['abc', 'def']
    o = [[['abc', 'def']]]
    assert divide(s) == o
    assert merge(o) == s
  end

  test "splitting of 4x4 grid" do
    s = ['abcd', 'efgh', 'hijk', 'klmn']
    o = [[['ab', 'ef'], ['cd', 'gh']], [['hi', 'kl'], ['jk', 'mn']]]
    assert divide(s) == o
    assert merge(o) == s
  end

  test "splitting to 9x9 grid" do
    s = ['abcdefghi', 'jklmnopqr', 'stuvwxyz0',
         '123456789', 'abcdefghi', 'jklmnopqr',
         'stuvwxyz0', '123456789', 'abcdefghi']

    o = [
      [['abc', 'jkl', 'stu'], ['def', 'mno', 'vwx'], ['ghi', 'pqr', 'yz0']],
      [['123', 'abc', 'jkl'], ['456', 'def', 'mno'], ['789', 'ghi', 'pqr']],
      [['stu', '123', 'abc'], ['vwx', '456', 'def'], ['yz0','789', 'ghi']]]

    assert divide(s) == o
    assert merge(o) == s
  end

  test "flip horizontal" do
    assert flip_horizontal(@start) == ['###', '..#', '.#.']
    assert flip_horizontal(@start) |> flip_horizontal == @start
  end

  test "flip vertical" do
    assert flip_vertical(@start) == ['.#.', '#..', '###']
    assert flip_vertical(@start) |> flip_vertical == @start
  end

  test "rotate" do
    assert rotate90(@start) == ['#..', '#.#', '##.']
    assert rotate180(@start) == ['###', '#..', '.#.']
    assert rotate270(@start) == ['.##', '#.#', '..#']
    assert rotate180(@start) |> rotate180 == @start
  end

  test "day 21 part 1" do
    rules = load_rules()
    art = generate_some_art(@start, rules, 5)
    assert lights_on(art) == 188
  end

  @tag timeout: 120_000
  test "day 21 part 2" do
    rules = load_rules()
    art = generate_some_art(@start, rules, 18)
    assert lights_on(art) == 0
  end
end
