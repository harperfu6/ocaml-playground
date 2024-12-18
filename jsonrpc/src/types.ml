open Yojson
open Errors

type id = int64

(* Type of error code defined by specification of JSON RPC *)
module Error_code = struct
  type t =
    | Parse_error
    | Invalid_request
    | Method_not_found
    | Invalid_params
    | Internal_error
    | Others of int

  let of_int = function
    | -32700 -> Parse_error
    | -32600 -> Invalid_request
    | -32601 -> Method_not_found
    | -32602 -> Invalid_params
    | -32603 -> Internal_error
    | _ as v -> Others v

  let to_int = function
    | Parse_error ->  -32700
    | Invalid_request ->  -32600
    | Method_not_found ->  -32601
    | Invalid_params ->  -32602
    | Internal_error ->  -32603
    | Others v -> v
end


(* Type of error object *)
type error = {
  code: Error_code.t;
  message: string;
  data: Basic.t option; (* t is Yojson.Basic.t *)
}

(* All structures for JSON RPC *)
type 'a response_handler = ('a, error) result -> unit

type jsonrpc =
  | Request of {_method: string; params: Basic.t option; id: id}
  | Response_success of {result: Basic.t; id: id}
  | Respnse_error of {error: error; id: id option}
  | Notification of {_method: string; params: Basic.t option}

let jsonrpc_version = ("jsonrpc", `String "2.0")

(* conversion functions between json and Ocaml *)
let _request id _method params =
  let id' = match id with
    | Some id -> [("id", `String (Int64.to_string id))]
    | None -> []
  in
  let _method' = ("method", `String _method) in
  let param' = match params with
    | Some params -> [("params", params)]
    | None -> []
  in
  `Assoc ([jsonrpc_version; _method';] @ param' @id')

let _response_success id result =
  let id' = ("id", `String (Int64.to_string id)) in
  `Assoc ([jsonrpc_version; id'; ("result", result)])

let _error error =
  let code = ("code", `Int (Error_code.to_int error.code)) in
  let message = ("message", `String error.message) in
  let data = match error.data with
    | Some data -> [("data", data)]
    | None -> []
  in
  `Assoc ([jsonrpc_version; code; message] @ data)

let _response_error id error =
  let id' = match id with
    | Some id -> [("id", `String (Int64.to_string id))]
    | None -> [("id", `Null)]
  in
  let error' = _error error in
  `Assoc ([jsonrpc_version; ("error", error')] @ id')

(* Convert jsonrpc object to json *)
let jsonrpc_to_json = function
  | Request v -> _request (Some v.id) v._method v.params
  | Notification v -> _request None v._method v.params
  | Response_success v -> _response_success v.id v.result
  | Respnse_error v -> _response_error v.id v.error


module Predicates = struct

  let has_error_code assoc =
    match List.assoc_opt "code" assoc with
    | Some (`Int _) -> true
    | _ -> false

  let has_error_message assoc =
    match List.assoc_opt "message" assoc with
    | Some (`String _) -> true
    | _ -> false

  let is_error = function
    | `Assoc assoc -> (has_error_code assoc && has_error_message assoc)
    | _ -> false

  let has_version assoc =
    List.assoc_opt "jsonrpc" assoc = Some (`String "2.0")

  let has_params assoc =
    match List.assoc_opt "params" assoc with
    | Some _ -> true
    | None -> false

  let has_id assoc =
    match List.assoc_opt "id" assoc with
    | Some (`String _) -> true
    | _ -> false

  let has_nullable_id assoc =
    match List.assoc_opt "id" assoc with
    | Some (`String _) | Some `Null -> true
    | _ -> false

  let has_method assoc =
    match List.assoc_opt "method" assoc with
    | Some (`String _) -> true
    | _ -> false

  let has_error assoc =
    match List.assoc_opt "error" assoc with
    | Some err -> is_error err
    | None -> false

  let has_result assoc =
    match List.assoc_opt "result" assoc with
    | Some _ -> true
    | None -> false
end

let is_request assoc =
  Predicates.(
    has_version assoc
    && has_id assoc
    && has_method assoc
    && has_params assoc
  )

let is_notification assoc =
  Predicates.(
    has_version assoc
    && not @@ has_id assoc
    && has_method assoc
    && has_params assoc
  )

let is_response_success assoc =
  Predicates.(
    has_version assoc
    && has_result assoc
    && has_id assoc
    && not @@ has_error assoc
  )

let is_response_error assoc =
  Predicates.(
    has_version assoc
    && not @@ has_result assoc
    && has_id assoc
    && has_error assoc
  )


(* Convert json object to jsonrpc type *)
let jsonrpc_of_json obj =
  let parse_error obj =
    match obj with
    | `Assoc lst -> begin
        let to_data lst =
          match List.assoc_opt "data" lst with
          | Some data -> Some data
          | None -> None
        in
        {
          code = Error_code.of_int @@ Basic.Util.to_int @@ List.assoc "code" lst;
          message = Basic.Util.to_string @@ List.assoc "message" lst;
          data = to_data lst;
        }
      end
    | _ -> failwith "Invalid format of error object"
  in
  let parse_requet assoc =
    let id = List.assoc_opt "id" assoc
    and _method = List.assoc_opt "method" assoc
    and params = List.assoc_opt "params" assoc in
    match (id, _method) with
    | (None, Some m) -> Ok (Notification {_method = Basic.Util.to_string m; params})
    | (Some id, Some m) -> Ok (Request {
        id = Int64.of_string @@ Basic.Util.to_string id;
        _method = Basic.Util.to_string m;
        params
      })
    | _ -> Error Not_found_version
  in
  let parse_response_error assoc =
    let id = List.assoc_opt "id" assoc
    and error = List.assoc_opt "error" assoc in
    let id' = match id with
      | Some id -> Some (Int64.of_string @@ Basic.Util.to_string id)
      | None -> None
    in
    match error with
    | Some e -> Ok (Respnse_error {error = parse_error e; id = id'})
    | _ -> Error Invalid_response
  in
  let parse_response_success assoc =
    let id = List.assoc "id" assoc
    and result = List.assoc_opt "result" assoc in
    match result with
    | Some e -> Ok (Response_success {result = e; id = Int64.of_string @@ Basic.Util.to_string id})
    | _ -> Error Invalid_response
  in

  let parse_obj obj =
    match obj with
    | `Assoc lst -> begin
        if is_request lst then parse_requet lst
        else if is_notification lst then parse_requet lst
        else if is_response_error lst then parse_response_error lst
        else if is_response_success lst then parse_response_success lst
        else Error (Invalid_object obj)
      end
    | _ -> Error (Invalid_object obj)
  in
  match obj with
  | `Null -> Error Empty_json
  | `Assoc _ -> parse_obj obj
  | _ -> Error (Invalid_object obj)



module Test = struct

  let tests = [
    "should be able to parse reponse object from json", (fun () ->
        let json = {|
          {"jsonrpc": "2.0", "result": 19, "id": "1"}
        |}
        in
        let expected = Response_success {id=1L; result=`Int 19} in
        jsonrpc_of_json (Yojson.Basic.from_string json) = Ok expected
      );
  ]
end

























