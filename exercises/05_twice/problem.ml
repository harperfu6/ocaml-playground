open! Base

let add1 x = x + 1
let square x = x * x
let twice f x = f (f x)

let%test "Testing add1..." =
  Int.(=) 5 (twice add1 3)