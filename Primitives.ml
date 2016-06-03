(** Binary primitives *)
let bin_op = 
  [| (0.25,"+", fun a b -> a +. b);
     (0.20,"-", fun a b -> a -. b);
     (0.25,"*", fun a b -> a *. b);
     (0.20,"/", fun a b -> a /. b);
     (0.10,"^", fun a b -> a ** b) |]

(** Unary primitives *)
let un_op = 
  [| (0.2,"cos", fun a -> cos a);
     (0.2,"sin", fun a -> sin a);
     (0.2,"tan", fun a -> tan a);
     (0.2,"ln", fun a -> log a);
     (0.2,"exp", fun a -> exp a) |]

(** Default params - Tweak them as you want *)
let default_params =
Dna.{
    fill_proba = 0.25 ;
    bin_op = bin_op ;
    bin_proba = 0.55 ;
    un_op = un_op;
    un_proba = 0.10 ;
    const_range = (-5.,5.) ;
    const_proba = 0.20 ;
    var_proba = 0.15
}
