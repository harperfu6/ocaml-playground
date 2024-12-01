open! Base

let simpler_sum xs = List.fold ~init:0 ~f:(+) xs
let simpler_product xs = List.fold ~init:1 ~f:( * ) xs

let float_of_int xs = List.map xs ~f:Float.of_int

(* let range from to_ = List.range from to_*)

let print_int_list xs = List.iter xs ~f:(Stdio.printf "%d")