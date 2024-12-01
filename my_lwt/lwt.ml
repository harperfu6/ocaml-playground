type time = float 

module Thunk = struct
  (* Jobs are stored as Thunk.t *)

  type t = unit -> unit
  let run t =
    (* 遅延されているタスク，条件が満たされると実行される *)
    t ()
end

(* 遅延タスクの種類
   - Ready: いつでも実行可能なタスク
   - Timed: ある時間が来たら実行可能なタスク
   - Fd: あるファイルハンドルが読み/書き可能になったら実行可能なタスク
*)

(* Ready *)
module Ready : sig
  (* ready thunk store : いつでも実行可能 *)
  type t 

  val create : unit -> t
  val add : t -> Thunk.t -> unit
  val take : t -> Thunk.t (* Take one of thunks from [t]. If none, rase Not_found *)
end = struct

  type t = Thunk.t Queue.t (* Queueインスタンスを作成しているだけ *)

  let create = Queue.create
  let add t thunk = Queue.add thunk t
  let take t =
    try
      Queue.take t
    with Queue.Empty -> raise Not_found
end

(* Timed *)
module Timed : sig
  (* timed thunk store *)
  type t

  (* 時間指定したタスクを足す *)
  val add : t -> time -> Thunk.t -> unit
  (* 時間が過ぎた実行すべきタスクを取り出す *)
  val get_expired : t -> time -> (time * Thunk.t) list
  (* 次のタイマーイベント *)
  val next_expiration : t -> time option
end = struct
  (* OcamlのstdlibにはヒープがないのでSetで実装する *)
  module Set =
    Set.Make(struct
      type t = time * Thunk.t
      let compare ((at1 : time), _) ((at2 : time), _) = compare at1 at2
    end)

  type t = Set.t ref 

  let create () = ref Set.empty
  let add t at v = t := Set.add (at, v) !t
  let get_expired t now =
    let expired, not_yet = Set.partition (fun (at,_) -> at <= now) !t in
    t := not_yet;
    Set.elements expired
  let next_expiration t = try Some (fst (Set.min_elt !t)) with Not_found -> None
end

(* Fd *)
module Fd : sig
  type t

  val create : unit -> t
  val add : t -> [`Read | `Write ] -> Unix.file_descr -> Thunk.t -> unit
  (* list up file descriptors for rad and write to select *)
  val waite_fds : t -> Unix.file_descr list * Unix.file_descr list
  (* [take t (rw, fd)] takes one of the thunks registered for given (rw, fd) from [t] and return t *)
  val take : t -> ([`Read | `Write] * Unix.file_descr) -> Thunk.t
end = struct
  module Hashtbl_list = struct
    (* Hashtbl with list *)
    open Hashtbl
    type ('a, 'b) t = ('a, 'b list) Hashtbl.t

    let create = create
    let find t k = try Hashtbl.find t k with Not_found -> []
    let add t k v = Hashtbl.replace t k (v :: find t k)
    let to_alist tbl =
      (* 空は除外しないとthunkの無いfdで待ってしまう *)
      List.filter (function (_, []) -> false | _ -> true) (Hashtbl.fold (fun k v acc -> (k,v)::acc) tbl [])
    let replace t k = function
      | [] -> Hashtbl.remove t k
      | vs -> Hashtbl.replace t k vs
  end

  type t = ([`Read | `Write] * Unix.file_descr, Thunk.t) Hashtbl_list.t

  let create () = Hashtbl_list.create 101
  (* キー[(rw,fd)]に，バリュー[thunk]を登録 *)
  let add t rw fd thunk = Hashtbl_list.add t (rw,fd) thunk
  let to_alist = Hashtbl_list.to_alist

  (* [thunk]が登録されたキーを列挙 *)
  let waite_fds t =
    List.fold_left (fun (fds_read, fds_write) ((rw,fd),_) ->
        match rw with
        | `Read -> fd::fds_read, fds_write
        | `Write -> fds_read, fd::fds_write
      )
      ([],[]) (to_alist t)
  let take t rw_fd = 
    match Hashtbl_list.find t rw_fd with
    | [] -> assert false (* スケジューラーがちゃんとしていれば空のはずがないため，ここに来たらバグ *)
    | x::xs -> Hashtbl_list.replace t rw_fd xs; x

end





















