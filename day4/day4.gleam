import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Input =
  List(List(String))

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day4/input.txt")
  let input = parse_input(raw_input)
  io.println("Part 1:")
  part1(input)
  |> io.debug
}

fn parse_input(raw_input: String) -> Input {
  raw_input
  |> string.trim
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn part1(input: Input) {
  let horizontal =
    input
    |> list.map(count_xmas(_, 0))
    |> int.sum

  let vertical =
    input
    |> list.transpose
    |> list.map(count_xmas(_, 0))
    |> int.sum

  let r_diagonal =
    input
    |> diagonals
    |> list.map(count_xmas(_, 0))
    |> int.sum

  let l_diagonal =
    input
    |> list.map(list.reverse)
    |> diagonals
    |> list.map(count_xmas(_, 0))
    |> int.sum

  horizontal + vertical + r_diagonal + l_diagonal
}

fn diagonals(input: List(List(String))) {
  let cords =
    list.index_map(input, fn(l, i) {
      list.index_map(l, fn(v, j) { #(#(j, i), v) })
    })
    |> list.flatten
    |> dict.from_list

  let size = list.length(input) - 1

  list.range(0, size)
  |> list.fold([], fn(acc, i) {
    let up =
      list.range(0, i)
      |> list.fold([], fn(acc, j) { [#(0 + j, i - j), ..acc] })
    let down =
      list.range(0, i)
      |> list.fold([], fn(acc, j) { [#(size - j, size - { i - j }), ..acc] })

    [up, down, ..acc]
  })
  |> list.drop(1)
  |> list.filter(fn(x) { list.length(x) >= 4 })
  |> list.map(fn(x) {
    list.map(x, fn(c) { dict.get(cords, c) |> result.unwrap("") })
  })
}

fn count_xmas(line: List(String), count: Int) -> Int {
  case line {
    [_, _, _] | [_, _] | [_] | [] -> count
    ["X", "M", "A", "S", ..] | ["S", "A", "M", "X", ..] -> {
      let assert [_, ..tail] = line
      count_xmas(tail, count + 1)
    }
    [_, ..tail] -> count_xmas(tail, count)
  }
}
