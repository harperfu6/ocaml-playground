open! Base

(* let () =
  let array = Array.create ~len:5 "hello" in
  assert (String.(=) "hello" (array.(1)));
  array.(2) <- "hello world";
  assert (String.(=) "hello world" (array.(2))); *)

let double array : unit =
  Array.iteri array ~f:(fun i elem -> array.(i) <- elem * 2)

let%test "Testing double..." =
  let array = [|1;1;1|] in
  double array;
  [%compare.equal: int array] [|2;2;2|] array

let double_selectively array indices : unit =
  Array.iteri array
  (* ~f:(fun i elem -> if List.exists indices ~f:(fun le -> i = le) then array.(i) <- elem * 2 else array.(i) <- elem) *)
  ~f:(fun i elem -> if List.exists indices ~f:(fun le -> i = le) then array.(i) <- elem * 2)

let%test "Testing double_selectively..." = 
  let array = [| 1; 1; 1 |] in
  (double_selectively array [ 1 ]);
  [%compare.equal: int array] 
    [| 1; 2; 1 |]
    array

let%test "Testing double_selectively..." = 
  let array = [| 1; 2; 3; 4; 5 |] in
  double_selectively array [ 0; 2; 4];
  [%compare.equal: int array] 
    [| 2; 2; 6; 4; 10 |] 
    array


let double_matrix matrix : unit =
  Array.iteri matrix
  ~f:(fun r row ->
      Array.iteri row
      ~f:(fun c col -> row.(c) <- col * 2)
    )

let%test "Testing double_matrix..." = 
  let matrix = [| [| 1; 2; 3 |]; [| 1; 1; 1 |] |] in
  (double_matrix matrix);
  [%compare.equal: int array array] 
    [| [| 2; 4; 6 |]; [| 2; 2; 2 |] |] 
  matrix