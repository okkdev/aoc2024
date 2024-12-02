import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Direction {
  Undecided
  Ascending
  Descending
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day2/input.txt")
  let input = parse_input(raw_input)

  io.println("Part 1:")
  part1(input)
  |> io.debug
  io.println("Part 2:")
  part2(input)
  |> io.debug
}

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    string.split(x, " ")
    |> list.map(fn(n) { int.parse(n) |> result.unwrap(0) })
  })
}

fn part1(input: List(List(Int))) {
  list.map(input, check_safe)
  |> list.count(result.is_ok)
}

fn part2(input: List(List(Int))) {
  list.map(input, fn(line) {
    list.combinations(line, list.length(line) - 1)
    |> list.any(fn(x) { check_safe(x) |> result.is_ok })
  })
  |> list.count(fn(x) { x == True })
}

fn check_safe(line: List(Int)) {
  list.window_by_2(line)
  |> list.try_fold(Undecided, fn(state, x) {
    let y = x.1 - x.0
    case state {
      Undecided | Ascending if y <= 3 && y > 0 -> Ok(Ascending)
      Undecided | Descending if y >= -3 && y < 0 -> Ok(Descending)
      _ -> Error(Nil)
    }
  })
}
