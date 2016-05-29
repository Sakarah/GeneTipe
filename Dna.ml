type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;


let create_random ~max_depth =
    X (* Gabzcr <- A coder en priorité *)
;;


let take_dna max_depth =
    X (* Sakarah *)
;;

let crossover ~law ~max_depth base giver =
    X (* Sakarah *)
;;

let mutation ~law ~max_depth base =
    X (* Sakarah *)
;;

let rec eval x dna =
    try 
        match dna with
            | UnOp (_,op,t) -> op (eval x t)
            | BinOp (_,op,t1,t2) -> op (eval x t1) (eval x t2)
            | Const a -> a
            | X -> x
    with
        _ -> None
;;

let rec print = function
    | Const a -> print_float a
    | X -> print_char 'x'
    | UnOp (name,_,child) -> print_string name ; print_string "("; print child; print_string ")"
    | BinOp (name,_,child1, child2) -> print_string "(" ;  print child1; print_string ")" ; print_string name; print_string "(" ; print child2; print_string ")"
;;
