open Lib.Obandit

let doTest depth bm str =
  let module BM = (val (bm):Bandit) in
  let rsum = ref 0. in
  let a = ref 0 in
  let n = ref 0 in
  let getR a = if a>0 then 0.08 +. Random.float 0.08 else Random.float 0.89 in
  begin
    while !n < depth do
      begin
        let newR = getR !a in
        let newA = BM.getAction newR in
        begin
          rsum := !rsum +. newR;
          n := !n + 1;
          a := newA
        end
      end
    done;

    Printf.printf "%s: %f " str (!rsum /. (float_of_int !n));
    if (!rsum /. (float_of_int !n) > 0.4) then
      Printf.printf "coverrage.%s" ""
    else
      failwith "insufficient performance of the algorithm."
  end

let () =
  let module PEXP3 = struct
    let n = 2
    let explo = 0.7
  end
  in

  let exp3 = (module MakeExp3(PEXP3):Bandit) in
  let dtn n = doTest n exp3 "Exp3"; Printf.printf "%s" "\n" in
  List.iter dtn [3000;30000]

