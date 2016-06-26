type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;

let create_random func_list ~max_depth =
    let create_func = RandUtil.from_proba_list func_list in
    create_func ~max_depth
;;

let mutation func_list ~max_depth base =
    let mutate_func = RandUtil.from_proba_list func_list in
    mutate_func ~max_depth base
;;

let crossover func_list giver base =
    let crossover_func = RandUtil.from_proba_list func_list in
    crossover_func giver base
;;

let rec eval dna x =
    match dna with
        | UnOp (_,op,t) -> 
            let result = op (eval t x) in
            if classify_float result = FP_infinite then nan
            else result
        | BinOp (_,op,t1,t2) -> 
            let result = op (eval t1 x) (eval t2 x) in
            if classify_float result = FP_infinite then nan
            else result
        | Const a -> a
        | X -> x
;;

let rec depth = function
    | Const _ | X -> 0
    | UnOp (_,_,child) -> 1+(depth child)
    | BinOp (_,_,child1,child2) -> 1+ (max (depth child1) (depth child2))
;;

let rec to_string ?(bracket=false) = function
    | Const a -> Printf.sprintf "%.2f" a
    | X -> "x"
    | UnOp (name,_,child) -> name ^ "(" ^ (to_string child) ^ ")"
    | BinOp (symb,_,child1,child2) ->
        if bracket then "(" ^ (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2) ^ ")"
        else (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2)
;;

let print ppf dna = Format.fprintf ppf "%s" (to_string dna);;
