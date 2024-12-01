open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Soup



(* let get_title =
  let body = Lwt_main.run (Client.get(Uri.of_string "http://ocaml.jp/") >>= fun (resp,body) -> body |> Cohttp_lwt.Body.to_string) in 
  let title = (parse body) $ "title" |> R.leaf_text in
  print_endline title;
  (parse body) $ ".list1" |> fun ul -> ul $$ "~ *" |> elements |> iter (fun li -> trimmed_texts li |> String.concat ~sep:"\n" |> print_endline); *)





(*
(* SlackへPost *)
let send_slack body =
  let webhook_token = "" in
  let webhook_url = "https://hooks.slack.com/services/" ^ webhook_token  in
  let params = body in
  Client.post
    ~body: (Cohttp_lwt.Body.of_string ("{\"text\":\"" ^ params ^ "\"}"))
    (Uri.of_string webhook_url) >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  body

(* HTMLを取得 *)
let fetch_html =
  let target_url = "https://ocaml.org/" in
  Client.get
    (Uri.of_string target_url) >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  body

(* HTMLパース *)
let parse_html raw_html =
  Lwt.return((parse raw_html) $ "title" |> R.leaf_text)

(* main *)
let () =
  let res = fetch_html
    >>= parse_html
    >>= send_slack in
  print_endline ("result\n" ^ Lwt_main.run (res
  )) *)
