import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string
import simplifile

type Direction {
  Up
  Down
  Left
  Right
}

type Field {
  Guard
  Empty
  Blocked
  Walked
  WalkedAgain
}

type Map =
  Dict(#(Int, Int), Field)

type Log =
  Dict(#(Int, Int), #(Field, Direction))

type Position =
  #(Int, Int)

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day6/input.txt")
  let #(map, pos) = parse_input(raw_input)
  io.println("Part 1:")
  part1(map, pos)
  |> io.debug
  io.println("Part 2:")
  part2(map, pos)
  |> io.debug
}

fn parse_input(raw_input: String) {
  let map =
    raw_input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(row, y) {
      string.to_graphemes(row)
      |> list.index_map(fn(field, x) {
        #(#(x, y), case field {
          "#" -> Blocked
          "^" -> Guard
          _ -> Empty
        })
      })
    })
    |> list.flatten

  let assert Ok(field) = list.find(map, fn(field) { field.1 == Guard })

  #(dict.from_list(map), field.0)
}

fn part1(map: Map, pos: Position) {
  do_walk(map, pos, Up, dict.from_list([]))
  |> result.unwrap(dict.from_list([]))
  |> dict.values
  |> list.count(fn(field) { field == Walked || field == WalkedAgain })
}

fn part2(map: Map, pos: Position) {
  do_walk(map, pos, Up, dict.from_list([]))
  |> result.unwrap(dict.from_list([]))
  |> dict.to_list()
  |> list.filter(fn(f) { f.1 == Walked || f.1 == WalkedAgain })
  |> list.map(fn(f) {
    task.async(fn() {
      dict.insert(map, f.0, Blocked)
      |> do_walk(pos, Up, dict.from_list([]))
    })
  })
  |> list.map(task.await_forever)
  |> list.count(result.is_error)
}

fn do_walk(
  map: Map,
  pos: Position,
  dir: Direction,
  log: Log,
) -> Result(Map, Nil) {
  let circle = dict.get(log, pos) == Ok(#(WalkedAgain, dir))

  case circle, dict.get(map, pos) {
    False, Ok(Empty) | False, Ok(Guard) ->
      dict.insert(map, pos, Walked)
      |> do_walk(move(pos, dir), dir, dict.insert(log, pos, #(Walked, dir)))
    False, Ok(Walked) | False, Ok(WalkedAgain) ->
      dict.insert(map, pos, WalkedAgain)
      |> do_walk(
        move(pos, dir),
        dir,
        dict.insert(log, pos, #(WalkedAgain, dir)),
      )
    False, Ok(Blocked) -> {
      let new_dir = switch_dir(dir)
      do_walk(map, move_back(pos, dir) |> move(new_dir), new_dir, log)
    }
    True, _ -> Error(Nil)
    _, _ -> Ok(map)
  }
}

fn move(pos: Position, dir: Direction) -> Position {
  case dir {
    Up -> #(pos.0, pos.1 - 1)
    Right -> #(pos.0 + 1, pos.1)
    Down -> #(pos.0, pos.1 + 1)
    Left -> #(pos.0 - 1, pos.1)
  }
}

fn move_back(pos: Position, dir: Direction) -> Position {
  case dir {
    Up -> #(pos.0, pos.1 + 1)
    Right -> #(pos.0 - 1, pos.1)
    Down -> #(pos.0, pos.1 - 1)
    Left -> #(pos.0 + 1, pos.1)
  }
}

fn switch_dir(dir: Direction) -> Direction {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}
