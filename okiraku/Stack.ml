(* 通常版 *)
(* module MyStack = struct
  exception Empty

  type 'a stack = SNil
                | SCell of 'a * 'a stack

  let create = SNil
  let push st x = SCell (x, st)
  let top = function
    | SNil -> raise Empty
    | SCell (x, _) -> x
  let pop = function
    | SNil -> raise Empty
    | SCell (_, xs) -> xs
  let is_empty st = st = SNil
end *)

(* 参照型版 *)
module type MYSTACK = sig
  exception Empty
  type 'a stack
  val create : unit -> 'a stack ref
  val push : 'a stack ref -> 'a -> unit
  val top : 'a stack ref -> 'a
  val pop : 'a stack ref -> 'a stack ref
  val is_empty : 'a stack ref -> bool
end

module Mystack: MYSTACK = struct
  exception Empty
  type 'a stack = SNil
                | SCell of 'a * 'a stack
  
  let create () = ref SNil
  let push st x = st := SCell (x, !st)
  let top st =
    match !st with
    | SNil -> raise Empty
    | SCell (x, _) -> x
  let pop st = 
    match !st with
    | SNil -> raise Empty
    | SCell (x, xs) -> st := xs; st
  let is_empty st = !st = SNil

end       