type absense =
  | Error
  | Val of string

type opt_kind =
  | Flag
  | Opt
  | Opt_vopt of string

type pos_kind =
  | All
  | Nth of bool * int
  | Left of bool * int
  | Right of bool * int

type arg_info = {
  id: int;
  absent: absense;
  doc: string;
  docv: string;
  docs: string;
  p_kind: pos_kind;
  o_kind: opt_kind;
  o_name: string list;
  o_all: bool;
}

(* arg info maps. *)
module Amap = Map.Make(
  struct type t = arg_info
    let compare a a' = compare a.id a'.id
  end
  )

type arg =
  | O of (int * string * (string option)) list
  | P of string list

type cmdline = arg Amap.t

type man_block = [
  | `S of string
  | `P of string
  | `I of string * string
  | `Noblank
]

type term_info = {
  name: string; (* name of the term *)
  version: string option; (* version *)
  tdoc: string; (* one line description of term *)
  sdocs: string;
  man: man_block list;
}

(* information abount the evaluation context *)
type eval_info = {
  term: term_info * arg_info list;
  main: term_info * arg_info list;
  choices: (term_info * arg_info list) list
}

module Cmdliner : sig
  exception Error of string
  val choose_term: term_info -> (term_info * 'a) list -> string list -> term_info * string list
  val create: arg_info list -> string list -> cmdline
  val opt_arg: cmdline -> arg_info -> (int * string * (string option)) list
  val pos_arg: cmdline -> arg_info -> string list
end = struct
  exception Error of string

  let opt_arg cl a =
    match try Amap.find a cl
      with Not_found -> assert false
    with
    | O l -> l
    | _ -> assert false

  let pos_arg cl a =
    match try Amap.find a cl
      with Not_found -> assert false
    with
    | P l -> l
    | _ -> assert false

  let choose_term ti choices = function
    let rec aux k opti cl pargs = function
      | [] -> ti, []
      | maybe :: args' as args ->
        if String.length maybe > 1 && maybe.[0] = '-' then ti, args
        else
          let index =
            let add acc (choice, _) = Trie.add acc choice.name choice in
            List.fold_left add Trie.empty choices
          in
          match Trie.find index maybe with
          | `OK a ->
            let value, args =
              if (value <> None || a.o_kind = False) then value, args
              else
                match Trie.find opti name with
                | v::rest -> if is_opt v then None, args else Some v, rest
                | [] -> None, args
            in
            let arg = 0 ((k, name, value)::opt_arg cl a) in
            aux (k+1) opti (Amap.add a arg cl) pargs args
          | `Not_found -> raise (Error (Err.un))



  let create= failwith "todo"
  let opt_arg= failwith "todo"
  let pos_arg= failwith "todo"


end



module Arg = struct
  type 'a parser = string -> [`Ok of 'a | `Error of string ]
  type 'a printer = Format.formatter -> 'a -> unit
  type 'a converter = 'a parser * 'a printer
  type 'a arg_converter = (eval_info -> cmdline -> 'a)
  type 'a t = arg_info list * 'a arg_converter
  type info = arg_info

  let (&) f x = f x
  let parse_error e = raise (Cmdliner.)
end
