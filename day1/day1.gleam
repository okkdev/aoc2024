import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Input {
  Input(left: List(Int), right: List(Int))
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day1/input.txt")
  let input = parse_input(raw_input)
  io.println("Part 1:")
  part1(input)
  |> io.debug
  io.println("Part 2:")
  part2(input)
  |> io.debug
}

fn parse_input(input: String) -> Input {
  input
  |> string.trim
  |> string.split("\n")
  |> list.fold(Input([], []), fn(acc, l) {
    let assert [a, b] =
      string.split(l, "   ")
      |> list.map(fn(n) { int.parse(n) |> result.unwrap(0) })
    Input([a, ..acc.left], [b, ..acc.right])
  })
}

fn part1(input: Input) -> Int {
  let left =
    input.left
    |> list.sort(int.compare)
  let right =
    input.right
    |> list.sort(int.compare)

  list.zip(left, right)
  |> list.fold(0, fn(acc, x) { acc + int.absolute_value(x.0 - x.1) })
}

fn part2(input: Input) -> Int {
  list.fold(input.left, 0, fn(acc, a) {
    acc + a * list.count(input.right, fn(b) { a == b })
  })
}
