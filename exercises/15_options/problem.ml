open! Base

type 'a option =
  | None
  | Some of 'a

let what_number_am_i_thinking (my_number : int option) =
  match my_number with
  | None -> "I'm not thinking of any number!"
  | Some number -> "My number is: " ^ (Int.to_string number)

let%test _ =
  String.(=) (what_number_am_i_thinking None) "I'm not thinking of any number!"

let%test _ =
  String.(=) (what_number_am_i_thinking (Some 7)) "My number is: 7"