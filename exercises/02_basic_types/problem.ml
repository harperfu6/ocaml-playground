open Base

let int_average x y = (x + y) / 2
let float_average x y = (x +. y) /. 2.



let%test "Testing int_average..." =
    Int.(=) (int_average 5 5) 5

let%test "Testing float_average..." =
    Float.(=) (float_average 5. 5.) 5.