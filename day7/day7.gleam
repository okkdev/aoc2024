import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

type Input =
  List(#(Int, List(Int)))

type Operation {
  Add
  Mul
  Conc
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day7/test.txt")
  let input = parse_input(raw_input)
  io.println("Part 1:")
  part1(input)
  |> io.debug
  io.println("Part 2:")
  part2(input)
  |> io.debug
}

fn parse_input(raw_input: String) {
  string.trim(raw_input)
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(control, values)) = string.split_once(line, ": ")
    let nums =
      string.split(values, " ")
      |> list.map(fn(num) { int.parse(num) |> result.unwrap(0) })
    #(int.parse(control) |> result.unwrap(0), nums)
  })
}

fn part1(input: Input) {
  solve(input, [Add, Mul])
}

fn part2(input: Input) {
  solve(input, [Add, Mul, Conc])
}

fn solve(input: Input, operators: List(Operation)) {
  input
  |> list.map(fn(line) {
    let #(control, values) = line
    let assert [first, ..rest] = values
    product(operators, list.length(values) - 1)
    |> list.fold_until(0, fn(_acc, ops) {
      let res = check(ops, rest, first)
      case control == res {
        True -> Stop(res)
        False -> Continue(0)
      }
    })
  })
  |> int.sum
}

fn check(ops: List(Operation), values: List(Int), acc: Int) {
  case ops, values {
    [Add, ..ops], [n, ..rest] -> check(ops, rest, acc + n)
    [Mul, ..ops], [n, ..rest] -> check(ops, rest, acc * n)
    [Conc, ..ops], [n, ..rest] -> {
      let n =
        int.parse(int.to_string(acc) <> int.to_string(n))
        |> result.unwrap(0)
      check(ops, rest, n)
    }
    _, _ -> acc
  }
}

fn product(a: List(a), size: Int) {
  case size {
    0 -> [[]]
    _ ->
      list.flat_map(a, fn(a1) {
        product(a, size - 1)
        |> list.map(fn(a2) { [a1, ..a2] })
      })
  }
}
