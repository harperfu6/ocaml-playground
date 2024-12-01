open Yojson

type t =
  (* The exception thrown when toplevel json is null *)
  | Empty_json
  | Invalid_object of Basic.t
  | Invalid_request
  | Invalid_response
  | Not_found_version
