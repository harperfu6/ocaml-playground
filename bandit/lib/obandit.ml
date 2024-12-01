module type BanditParam = sig
  val n : int
  val explo : float
end

module type Bandit = sig
  val getAction : float -> int
end

module MakeExp3 (P:BanditParam): Bandit = struct
  let a = ref (-1)
  let w = Array.make P.n 1.
  let k = ref 1

  let wTop sum w = ((1.0 -. P.explo) *. (w /. sum)) +. (P.explo /. (float_of_int !k))

  let getAction x =
    if !a < 0 then
      let x = Random.int P.n in
      a:=x; x
    else
      let () =
        let oldSum = Array.fold_left (fun acc x -> x +. acc) 0.0 w in
        w.(!a) <- w.(!a) *. (exp (P.explo *. x /. ((float_of_int !k) *. (wTop oldSum w.(!a)))));
      in
      let p =
        let sum = Array.fold_left (fun acc x -> x +. acc) 0.0 w in
        Array.map (fun w -> ((1.0 -. P.explo) *. (w /. sum)) +. (P.explo /. (float_of_int !k))) w
      in
      let r =
        let sump = Array.fold_left (fun acc x -> x +. acc) 0.0 p in
        Random.float sump
      in
      let rec sample i acc =
        if i+2=P.n then i+1
        else if (acc +. p.(i+1) > r) then
          i+1
        else
          sample (i+1) (acc +. p.(i+1))
      in
      let newA = sample (-1) 0.
      in
      a:=newA;
      k:=!k+1;
      newA
end




(* (* inline test *)     *)
(* module PEXP3 = struct *)
(*   let n = 2           *)
(*   let explo = 0.7     *)
(* end                   *)

(* let                   *)
