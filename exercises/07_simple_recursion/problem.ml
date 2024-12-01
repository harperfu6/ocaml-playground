open! Base

let rec factorial x =
  assert (x >= 0);
  match x with
  | 0 -> 1
  | _ -> x * factorial (x - 1)

let%test "test" = Int.(=) 1 (factorial 0)
let%test "test" = Int.(=) 120 (factorial 5)
let%test "test" = Int.(=) 479001600 (factorial 12)