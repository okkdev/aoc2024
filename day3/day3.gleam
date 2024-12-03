import gleam/bit_array
import gleam/int
import gleam/io
import gleam/result
import simplifile

pub fn main() {
  let assert Ok(raw_input) = simplifile.read("src/day3/input.txt")
  let input = raw_input |> bit_array.from_string
  io.println("Part 1:")
  part1(input, 0)
  |> io.debug
  io.println("Part 2:")
  part2(input, True, 0)
  |> io.debug
}

fn part1(input: BitArray, acc: Int) -> Int {
  case input {
    <<>> -> acc
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
      part1(res, acc + a * b)
    }
    _ -> {
      let assert <<_:bytes-size(1), res:bytes>> = input
      part1(res, acc)
    }
  }
}

fn part2(input: BitArray, enabled: Bool, acc: Int) -> Int {
  case enabled, input {
    _, <<>> -> acc
    _, <<"do()", res:bytes>> -> part2(res, True, acc)
    _, <<"don't()", res:bytes>> -> part2(res, False, acc)
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
      part2(res, enabled, acc + a * b)
    }
    _, _ -> {
      let assert <<_:bytes-size(1), res:bytes>> = input
      part2(res, enabled, acc)
    }
  }
}

fn bit_to_int(bit_array: BitArray) -> Int {
  bit_array.to_string(bit_array)
  |> result.unwrap("0")
  |> int.parse
  |> result.unwrap(0)
}
