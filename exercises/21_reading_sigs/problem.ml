open Base

module Abstract_type_example : sig
  (* We do not let the user know the underlying representation of [t]. *)
  type t

  (* This function allows [t] to be coerced into an integer. *)
  val to_int : t -> int

  (* Users need some way to start with some [t]. *)
  val zero : t
  val one : t

  (* Let them do something with the [t]. *)
  val add : t -> t -> t
end = struct
  type t = int

  let to_int x = x
  let zero = 0
  let one = 1
  let add = ( + )
end

module Fraction : sig
  type t

  val create : numerator:int -> denominator:int -> int * int
  val value : int * int -> float
end = struct
  type t = int * int

  let create ~numerator ~denominator = numerator, denominator
  let value (numerator, denominator) = Float.of_int numerator /. Float.of_int denominator
end

let%test "Testing Fraction.value..." =
  Float.(=) 2.5 (Fraction.value (Fraction.create ~numerator:5 ~denominator:2))