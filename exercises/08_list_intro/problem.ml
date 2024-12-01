open! Base

let () =
  assert ([%compare.equal: int list] [5;1;8;4] (5::1::8::4::[]))

let rec sum lst =
  match lst with
  | [] -> 0
  | hd :: tl -> hd + sum tl

let%test "Testing sum..." = Int.( = ) 0 (sum [])
let%test "Testing sum..." = Int.( = ) 55 (sum [ 55 ])
let%test "Testing sum..." = Int.( = ) 0 (sum [ 5; -5; 1; -1 ])
let%test "Testing sum..." = Int.( = ) 12 (sum [ 5; 5; 1; 1 ])
