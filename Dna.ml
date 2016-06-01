type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;

exception IllFormed;;

type randomGenParams =
{
    fill_proba: float;
    bin_op:(float * string * (float -> float -> float)) array ;
    bin_proba:float ;
    un_op:(float * string * (float -> float)) array ;
    un_proba:float ;
    const_range:(float*float) ;
    const_proba:float
};;

(** Generate a uniform random float value in specified range *)
let uniform_float (lower_bound,greater_bound) =
    (Random.float (greater_bound-.lower_bound)) +. lower_bound
;;

let create_random_grow ~max_depth random_gen_params =
    X (* Skodt *)
;;

let create_random_fill ~max_depth random_gen_params =
    X (* Gabzcr *)
;;

let create_random ~max_depth random_gen_params =
    if Random.float 1. < random_gen_params.fill_proba then create_random_fill ~max_depth random_gen_params
    else create_random_grow ~max_depth random_gen_params
;;

let rec take_graft depth = function
    | dna when depth = 0 -> dna
    | BinOp (_,_,child1,_) when Random.bool () -> take_graft (depth-1) child1
    | BinOp (_,_,_,child2) -> take_graft (depth-1) child2
    | UnOp (_,_,child) -> take_graft (depth-1) child
    | dna -> dna
;;

let crossover ~crossover_depth base giver =
    let rec crossov depth = function
        | _ when depth = crossover_depth -> take_graft depth giver
        | BinOp (n,f,child1,child2) when Random.bool () -> BinOp (n,f,crossov (depth+1) child1,child2)
        | BinOp (n,f,child1,child2) -> BinOp (n,f,child1,crossov (depth+1) child2)
        | UnOp (n,f,child) -> UnOp (n,f,crossov (depth+1) child)
        | _ -> take_graft depth giver
    in
    crossov 0 base
;;

let mutation ~mutation_depth ~max_depth random_gen_params base =
    let rec mutate depth = function
        | _ when depth = mutation_depth -> create_random ~max_depth:(max_depth-mutation_depth) random_gen_params
        | BinOp (n,f,child1,child2) when Random.bool () -> BinOp (n,f,mutate (depth+1) child1,child2)
        | BinOp (n,f,child1,child2) -> BinOp (n,f,child1,mutate (depth+1) child2)
        | UnOp (n,f,child) -> UnOp (n,f,mutate (depth+1) child)
        | _ -> create_random ~max_depth:(max_depth-depth) random_gen_params
    in
    mutate 0 base
;;

let mutate_constants ~range ~proba base =
    let rec mutate = function
        | BinOp (name,func,child1,child2) -> BinOp (name, func, mutate child1, mutate child2)
        | UnOp (name,func,child) -> UnOp (name, func, mutate child)
        | Const a when Random.float 1. < proba -> Const (a +. uniform_float range)
        | dna -> dna
    in
    mutate base
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
    | BinOp (symb,_,child1,child2) ->
        if bracket then "(" ^ (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2) ^ ")"
        else (to_string ~bracket:true child1) ^ symb ^ (to_string ~bracket:true child2)
;;

let print ppf dna = Format.fprintf ppf "%s" (to_string dna);;
