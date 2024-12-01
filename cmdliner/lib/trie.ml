module Trie : sig
  type 'a t
  val empty: 'a t
  val is_empty: 'a t -> bool
  val add: 'a t -> string -> 'a -> 'a t
  val find: 'a t -> string -> [ `Ok of 'a | `Ambiguous | `Not_found ]
  val ambiguities: 'a t -> string -> string list
  val of_list: (string * 'a) list -> 'a t
end = struct
  module Cmap = Map.Make(Char)
  type 'a value =
    | Pre of 'a (* value is bound by the prefix of a key. *)
    | Key of 'a (* value is bound by an entire key. *)
    | Amb (* no value bound because of ambiguous prefix. *)
    | Nil (* no bound (only for the empty trie). *)

  type 'a t = {
    v: 'a value;
    succs: 'a t Cmap.t;
  }

  let empty ={
    v = Nil;
    succs = Cmap.empty;
  }

  let is_empty t =
    t = empty

  let add t k d =
    let rec aux t k len i d pre_d =
      if i = len then { v = Key d; succs = t.succs }
      else
        let v = match t.v with
          | Amb | Pre _ -> Amb
          | Key _ as v -> v
          | Nil -> pre_d
        in
        let succs =
          let t' =
            try
              Cmap.find k.[i] t.succs
            with
              Not_found -> empty
          in
          Cmap.add k.[i] (aux t' k len (i+1) d pre_d) t.succs
        in
        { v; succs }
    in
    aux t k (String.length k) 0 d (Pre d)

  let find_node t k =
    let rec aux t k len i =
      if i = len then t
      else
        aux (Cmap.find k.[i] t.succs) k len (i+1)
    in
    aux t k (String.length k) 0

  let find t k =
    try match (find_node t k).v with
      | Key v | Pre v -> `Ok v
      | Amb -> `Ambiguous
      | Nil -> `Not_found
    with
      Not_found -> `Not_found

  let ambiguities t p =
    try
      let t = find_node t p in
      match t.v with
      | Key _ | Pre _ | Nil -> []
      | Amb ->
        let add_char s c = s ^ (String.make 1 c) in
        let rem_char s = String.sub s 0 ((String.length s) - 1) in
        let to_list m = Cmap.fold (fun k t acc -> (k,t)::acc) m [] in
        let rec aux acc p = function
          | ((c,t)::succs)::rest ->
            let p' = add_char p c in
            let acc' = match t.v with
              | Pre _ | Amb -> acc
              | Key _ -> (p'::acc)
              | Nil -> assert false
            in
            aux acc' p' ((to_list t.succs)::succs::rest)
          | []::[] -> acc
          | []::rest -> aux acc (rem_char p) rest
          | [] -> assert false
        in
        aux [] p (to_list t.succs::[])
    with
      Not_found -> []

  let of_list l =
    List.fold_left (fun t (s,v) -> add t s v) empty l
end
