import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day3/input.txt")
  let input = raw_input |> bit_array.from_string
  io.println("Part 1:")
  part1(input)
  |> io.debug
  io.println("Part 2:")
  part2(input, True)
  |> io.debug
}

fn part1(input: BitArray) -> Int {
  case input {
    <<>> -> 0
    <<"mul(", a:bytes-size(1), ",", b:bytes-size(1), ")", res:bytes>>
    | <<"mul(", a:bytes-size(1), ",", b:bytes-size(2), ")", res:bytes>>
    | <<"mul(", a:bytes-size(2), ",", b:bytes-size(1), ")", res:bytes>>
    | <<"mul(", a:bytes-size(2), ",", b:bytes-size(2), ")", res:bytes>>
    | <<"mul(", a:bytes-size(1), ",", b:bytes-size(3), ")", res:bytes>>
    | <<"mul(", a:bytes-size(3), ",", b:bytes-size(1), ")", res:bytes>>
    | <<"mul(", a:bytes-size(2), ",", b:bytes-size(3), ")", res:bytes>>
    | <<"mul(", a:bytes-size(3), ",", b:bytes-size(2), ")", res:bytes>>
    | <<"mul(", a:bytes-size(3), ",", b:bytes-size(3), ")", res:bytes>> -> {
      let a = bit_to_int(a)
      let b = bit_to_int(b)
      a * b + part1(res)
    }
    _ -> {
      let assert <<_:bytes-size(1), res:bytes>> = input
      part1(res)
    }
  }
}

fn part2(input: BitArray, enabled: Bool) -> Int {
  case enabled, input {
    _, <<>> -> 0
    _, <<"do()", res:bytes>> -> part2(res, True)
    _, <<"don't()", res:bytes>> -> part2(res, False)
    True, <<"mul(", a:bytes-size(1), ",", b:bytes-size(1), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(1), ",", b:bytes-size(2), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(2), ",", b:bytes-size(1), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(2), ",", b:bytes-size(2), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(1), ",", b:bytes-size(3), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(3), ",", b:bytes-size(1), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(2), ",", b:bytes-size(3), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(3), ",", b:bytes-size(2), ")", res:bytes>>
    | True, <<"mul(", a:bytes-size(3), ",", b:bytes-size(3), ")", res:bytes>>
    -> {
      let a = bit_to_int(a)
      let b = bit_to_int(b)
      a * b + part2(res, enabled)
    }
    _, _ -> {
      let assert <<_:bytes-size(1), res:bytes>> = input
      part2(res, enabled)
    }
  }
}

fn solve(input: BitArray) -> Int {
  todo
}

fn bit_to_int(bit_array: BitArray) -> Int {
  bit_array.to_string(bit_array)
  |> result.unwrap("0")
  |> int.parse
  |> result.unwrap(0)
}
