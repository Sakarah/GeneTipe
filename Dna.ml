type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;

exception IllFormed;;


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
        _ -> raise IllFormed
;;

let rec to_string ?(bracket=false) = function
    | Const a -> Printf.sprintf "%.2f" a
    | X -> "x"
    | UnOp (name,_,child) -> name ^ "(" ^ (to_string child) ^ ")"
    | BinOp (symb,_,child1, child2) ->
        if bracket then "(" ^ (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2) ^ ")"
        else (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2)
;;

let print ppf dna = Format.fprintf ppf "%s" (to_string dna);;
