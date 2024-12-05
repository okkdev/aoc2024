import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Input {
  Input(rules: List(#(Int, Int)), pages: List(List(Int)))
}

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day5/input.txt")
  let input = parse_input(raw_input)
  io.println("Part 1:")
  part1(input)
  |> io.debug
  io.println("Part 2:")
  part2(input)
  |> io.debug
}

fn parse_input(raw_input: String) -> Input {
  let assert Ok(#(r, p)) =
    raw_input
    |> string.trim
    |> string.split_once("\n\n")

  let rules =
    string.split(r, "\n")
    |> list.map(fn(x) {
      let assert [a, b] =
        string.split(x, "|")
        |> list.map(fn(y) { int.parse(y) |> result.unwrap(0) })
      #(a, b)
    })

  let pages =
    string.split(p, "\n")
    |> list.map(fn(x) {
      string.split(x, ",")
      |> list.map(fn(y) { int.parse(y) |> result.unwrap(0) })
    })

  Input(rules:, pages:)
}

fn part1(input: Input) {
  satisfy(input)
  |> list.filter_map(fn(x) {
    case x {
      Ok(x) -> {
        get_center(x)
      }
      _ -> Error(Nil)
    }
  })
  |> int.sum
}

fn part2(input: Input) {
  satisfy(input)
  |> list.filter_map(fn(ps) {
    case ps {
      Ok(_) -> Error(Nil)
      Error(ps) -> {
        let ps = dict.keys(ps)
        list.fold(ps, ps, fn(acc, p) {
          let #(a, b) = list.split_while(acc, fn(x) { x != p })
          let matching_rules = list.key_filter(input.rules, p)
          let behind = list.filter(a, list.contains(matching_rules, _))
          use <- bool.guard(list.is_empty(behind), acc)
          let a = list.filter(a, fn(x) { !list.contains(behind, x) })
          let b = list.drop(b, 1)
          list.flatten([a, [p], behind, b])
        })
        |> list.index_map(fn(x, i) { #(x, i) })
        |> dict.from_list
        |> get_center
      }
    }
  })
  |> int.sum
}

fn get_center(value_index: Dict(Int, Int)) {
  let index_value =
    dict.to_list(value_index)
    |> list.map(fn(y) { #(y.1, y.0) })
    |> dict.from_list
  let i = dict.size(index_value) / 2
  dict.get(index_value, i)
}

fn satisfy(input: Input) {
  let pages =
    input.pages
    |> list.map(fn(x) {
      list.index_map(x, fn(x, i) { #(x, i) })
      |> dict.from_list
    })

  list.map(pages, fn(p) {
    list.try_fold(input.rules, p, fn(acc, r) {
      case dict.get(p, r.0), dict.get(p, r.1) {
        Ok(a), Ok(b) if a < b -> Ok(acc)
        Error(_), _ | _, Error(_) -> Ok(acc)
        _, _ -> Error(acc)
      }
    })
  })
}
