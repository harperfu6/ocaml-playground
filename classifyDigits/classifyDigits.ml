
let read_lines name : string list =
  let ic = open_in name in
  let try_read () =
    try
      Some (input_line ic)
    with
      End_of_file -> None
  in
  let rec loop acc =
    match try_read () with
    | Some s -> loop (s::acc)
    | None -> close_in ic; List.rev acc in
  loop []

type labelPixels = {
  label: int;
  pixels: int list
}
let slurp_file file =
  List.tl (read_lines file)
  |> List.map (fun line -> Str.split (Str.regexp ",") line)
  |> List.map (fun numline -> List.map (fun (x:string) -> int_of_string x) numline)
  |> List.map (fun line -> { label=(List.hd line); pixels=(List.tl line) })

let trainingset =  slurp_file("./trainingsample.csv")



let list_sum lst = List.fold_left (fun x acc -> x+acc) 0 lst

let distance (p1: int list) (p2: int list) =
  sqrt (float_of_int (list_sum (List.map2 (fun a b -> 
      let diff = a - b in
      diff*diff) p1 p2)))

let minBy f lst =
  let smallest = ref (List.hd lst) in
  List.iter (fun x -> if (f x) < (f !smallest) then smallest := x) (List.tl lst);
  !smallest;;

let classify (pixels: int list) =
  fst ((List.map (fun (x: labelPixels) -> (x.label, (distance pixels x.pixels) )) trainingset)
       |> minBy (fun x -> snd x))

let validationsample = slurp_file("./validationsample.csv")
let num_correct = (validationsample |> List.map (fun p -> if (classify p.pixels) = p.label then 1 else 0) |> list_sum)
let _ = Printf.printf "Percentage correct:%f\n" ((float_of_int(num_correct)/.(float_of_int(List.length validationsample)))*.100.0)
