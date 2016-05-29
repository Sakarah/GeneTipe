exception IllFormed

(*
** Binary primitives
*)

let bin_op = 
  [| ("+", fun a b = a +. b),
     ("-", fun a b = a -. b),
     ("*", fun a b = a *. b),
     ("/", fun a b = a /. b),
     ("^", fun a b = a ** b) |]

(*
** Unary primitives
*)

let un_op = 
  [| ("cos", fun a = cos a),
     ("sin", fun a = sin a),
     ("tan", fun a = tan a),
     ("ln", fun a = log a),
     ("exp", fun a = exp a) |]

