import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

pub type Report {
  Report(state: Safety, direction: Direction)
}

pub type Safety {
  Safe
  Unsafe
}

pub type Direction {
  Undecided
  Up
  Down
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day2/input.txt")
  let input = parse_input(raw_input)

  io.println("Part 1:")
  part1(input)
  |> io.debug
  // io.println("Part 2:")
  // part2(input)
  // |> io.debug
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
  input
  |> list.map(fn(x) {
    list.window_by_2(x)
    |> list.fold_until(Report(Safe, Undecided), fn(rep, y) {
      case rep.direction {
        Undecided ->
          case y.1 - y.0 {
            x if x <= 3 && x > 0 -> Continue(Report(Safe, Up))
            x if x >= -3 && x < 0 -> Continue(Report(Safe, Down))
            _ -> Stop(Report(Unsafe, Undecided))
          }
        x -> {
          let step = case x {
            Up -> y.1 - y.0
            Down -> y.0 - y.1
            _ -> 0
          }
          case step <= 3 && step > 0 {
            True -> Continue(Report(..rep, state: Safe))
            False -> Stop(Report(..rep, state: Unsafe))
          }
        }
      }
    })
  })
  |> list.count(fn(x) { x.state == Safe })
}
