open Base

type color =
  | Red
  | Yellow
  | Green
[@@deriving compare]

type stoplight =
  {
    location : string;
    mutable color : color
  } [@@deriving compare]

let an_example : stoplight =
  {
    location = "The corner of Vesey Street and the West Side highway";
    color = Red
  }

let set_color stoplight color = stoplight.color <- color

let advance_color stoplight =
  match stoplight.color with
  | Green -> stoplight.color <- Yellow
  | Yellow -> stoplight.color <- Red
  | Red -> stoplight.color <- Green


module For_testing = struct
  let test_ex_red : stoplight = { location = ""; color = Red }
  let test_ex_red' : stoplight = { test_ex_red with color = Green }
  let test_ex_yellow : stoplight = { location = ""; color = Yellow }
  let test_ex_yellow' : stoplight = { test_ex_red with color = Red }
  let test_ex_green : stoplight = { location = ""; color = Green }
  let test_ex_green' : stoplight = { test_ex_red with color = Yellow }

  let%test "Testing advance_color..." =
    advance_color test_ex_green;
    [%compare.equal: stoplight] test_ex_green' test_ex_green
  ;;

  let%test "Testing advance_color..." =
    advance_color test_ex_yellow;
    [%compare.equal: stoplight] test_ex_yellow' test_ex_yellow
  ;;

  let%test "Testing advance_color..." =
    advance_color test_ex_red;
    [%compare.equal: stoplight] test_ex_red' test_ex_red
  ;;

end