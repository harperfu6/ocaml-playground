open! Base

type color =
  | Red
  | Green
  | Blue

let to_string color = 
  match color with
  | Red -> "red"
  | Green -> "green"
  | Blue -> "blue"

type card_value =
  | Ace
  | King
  | Queen
  | Jack
  | Number of int

let one_card_value : card_value = Queen
let another_card_value : card_value = Number 8

let card_value_to_string card_value =
  match card_value with
  | Ace      -> "Ace"
  | King     -> "King"
  | Queen    -> "Queen"
  | Jack     -> "Jack"
  | Number i -> Int.to_string i

let card_value_to_score card_value =
  match card_value with
  | Ace      -> 11
  | Number i -> i
  | _        -> 10


let%test "Testing card_value_to_score..." =
  Int.(=) 11 (card_value_to_score Ace)

let%test "Testing card_value_to_score..." =
  Int.(=) 10 (card_value_to_score King)

let%test "Testing card_value_to_score..." =
  Int.(=) 10 (card_value_to_score Queen)

let%test "Testing card_value_to_score..." =
  Int.(=) 10 (card_value_to_score Jack)

let%test "Testing card_value_to_score..." =
  Int.(=) 5 (card_value_to_score (Number 5))