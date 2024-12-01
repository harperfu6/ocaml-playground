let str = Printf.sprintf
let quote s = str "`%s'" s

module Err = struct
  let alts = function
    | [a;b] -> str "either %s or %s" a b
    | alts -> str "one of: %s" (String.concat ", " alts)

  let invalid kind s exp = str "invalid %s %s, %s" kind (quote s) exp
end
