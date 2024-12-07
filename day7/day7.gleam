import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

type Input =
  List(#(Int, List(Int)))

type Value {
  Add
  Mul
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day7/input.txt")
  let input = parse_input(raw_input)
  io.println("Part 1:")
  part1(input)
  |> io.debug
  // io.println("Part 2:")
  // part2(map, pos)
  // |> io.debug
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
  input
  |> list.map(fn(line) {
    let #(control, values) = line
    let assert [first, ..rest] = values
    product([Add, Mul], list.length(values) - 1)
    |> list.fold_until(0, fn(_acc, ops) {
      let res =
        list.zip(ops, rest)
        |> list.fold(first, fn(acc, on) {
          let #(op, num) = on
          case op {
            Add -> acc + num
            Mul -> acc * num
          }
        })

      case res == control {
        True -> Stop(res)
        False -> Continue(0)
      }
    })
  })
  |> int.sum
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
