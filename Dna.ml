type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;

exception Found of int;;

type randomGenParams =
{
    fill_proba: float;
    bin_op:(float * string * (float -> float -> float)) array ;
    bin_proba:float ;
    un_op:(float * string * (float -> float)) array ;
    un_proba:float ;
    const_range:(float*float) ;
    const_proba:float ;
    var_proba:float
};;

(** Generate a uniform random float value in specified range *)
let uniform_float (lower_bound,greater_bound) =
    (Random.float (greater_bound-.lower_bound)) +. lower_bound
;;

(** Randomly chose a binary operation within the randomGenParams *)
let random_bin_op bin_op_params =
    let n = Array.length bin_op_params in
    let probs = Array.make n 0. in

    let proba (x,y,z) = x in
    let binop (x,y,z) = (y,z) in

    probs.(0) <- proba bin_op_params.(0) ;
    for i = 1 to n-2 do
        probs.(i) <- probs.(i-1) +. proba bin_op_params.(i)
    done;
    probs.(n-1) <- 1. ;

    try
        let p = Random.float 1. in
        for i = 0 to n-1 do
            if p < probs.(i) then raise (Found i)
        done;
        failwith "The probabilities are not well defined"
    with
        Found i -> binop bin_op_params.(i)
;;

(** Randomly chose a unary operation within the randomGenParams *)
let random_un_op un_op_params =
    let n = Array.length un_op_params in
    let probs = Array.make n 0. in

    let proba (x,y,z) = x in
    let unop (x,y,z) = (y,z) in

    probs.(0) <- proba un_op_params.(0) ;
    for i = 1 to n-2 do
        probs.(i) <- probs.(i-1) +. proba un_op_params.(i)
    done;
    probs.(n-1) <- 1. ;

    try
        let p = Random.float 1. in
        for i = 0 to n-1 do
            if p < probs.(i) then raise (Found i)
        done;
        failwith "The probabilities are not well defined"
    with
        Found i -> unop un_op_params.(i)
;;

let rec create_random_grow ~max_depth gen_params =
    (* If max_depth is reached, then there is a constant or a variable *)
    if max_depth = 0 then
    (
        let p = Random.float (gen_params.const_proba +. gen_params.var_proba) in
        if p < gen_params.const_proba then
            Const (uniform_float(gen_params.const_range))
        else
            X
    )
    else
    (
        let p_bin = gen_params.bin_proba in
        let p_un = p_bin +. gen_params.un_proba in
        let p_const = p_un +. gen_params.const_proba in

        let p = Random.float 1. in

        if p < p_bin then
            let name, operation = random_bin_op gen_params.bin_op in
            BinOp (name, operation, (create_random_grow (max_depth - 1) gen_params), (create_random_grow (max_depth - 1) gen_params) )
        else if p < p_un then
            let name, operation = random_un_op gen_params.un_op in
            UnOp (name, operation, (create_random_grow (max_depth - 1) gen_params))
        else if p < p_const then
            Const (uniform_float(gen_params.const_range))
        else
            X
    )
;;

let create_random_fill ~max_depth gen_params =
    X (* Gabzcr *)
;;

let create_random ~max_depth gen_params =
    if Random.float 1. < gen_params.fill_proba then create_random_fill ~max_depth gen_params
    else create_random_grow ~max_depth gen_params
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

let mutation ~mutation_depth ~max_depth gen_params base =
    let rec mutate depth = function
        | _ when depth = mutation_depth -> create_random ~max_depth:(max_depth-mutation_depth) gen_params
        | BinOp (n,f,child1,child2) when Random.bool () -> BinOp (n,f,mutate (depth+1) child1,child2)
        | BinOp (n,f,child1,child2) -> BinOp (n,f,child1,mutate (depth+1) child2)
        | UnOp (n,f,child) -> UnOp (n,f,mutate (depth+1) child)
        | _ -> create_random ~max_depth:(max_depth-depth) gen_params
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
    match dna with
        | UnOp (_,op,t) -> op (eval x t)
        | BinOp (_,op,t1,t2) -> op (eval x t1) (eval x t2)
        | Const a -> a
        | X -> x
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
