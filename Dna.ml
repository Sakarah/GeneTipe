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

let take_dna max_depth =
    X (* Sakarah *)
;;

let crossover ~depth base giver =
    X (* Sakarah *)
;;

let mutation ~depth random_gen_params base =
    X (* Sakarah *)
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
