open Types
open Yojson

(* Signature of to define interface of an API *)
module type Api_def = sig
  type params
  type result

  (* Return name of method *)
  val name: string

  (* Convert parameter to json *)
  val params_to_json: params option -> Basic.t option

  (* Convert json to result when request success. *)
  val result_of_json: Basic.t -> result
end

(* Module signature for Threading such as Lwt *)
module type Thread = sig
  type 'a t

  val bind: 'a t -> ('a -> 'b t) -> 'b t
  val return: 'a -> 'a t
end

module type Rpc = sig
  module Thread: Thread

  val call_api: jsonrpc -> handler: 'a response_handler -> unit Thread.t
end
