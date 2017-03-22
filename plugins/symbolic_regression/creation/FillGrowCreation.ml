(** Generate a random affin function *)
(*let random_affin const_range =
    FunctionDna.BinOp ("+", (fun a b -> a +. b),
        FunctionDna.BinOp ("*", (fun a b -> a *. b),
            FunctionDna.Const (uniform_float const_range),
            FunctionDna.X),
        FunctionDna.Const (uniform_float const_range))
;;*)

exception Found of int;;

open RandGenParams;;

(** Randomly choose an operation within the randomGenParams *)
let random_op op_params =
    let n = Array.length op_params in
    let probs = Array.make n 0. in

    let proba (x,y,z) = x in
    let op (x,y,z) = (y,z) in

    probs.(0) <- proba op_params.(0) ;
    for i = 1 to n-2 do
        probs.(i) <- probs.(i-1) +. proba op_params.(i)
    done;
    probs.(n-1) <- 1. ;

    try
        let p = Random.float 1. in
        for i = 0 to n-1 do
            if p < probs.(i) then raise (Found i)
        done;
        failwith "The probabilities are not well defined"
    with
        Found i -> op op_params.(i)
;;


(** Randomly generate a new individual who has a depth below max_depth *)
let rec create_random_grow gen_params ~max_depth =
    (* If max_depth is reached, then there is a constant or a variable *)
    if max_depth = 0 then
    (
        let p = Random.float (gen_params.const_proba +. gen_params.var_proba) in
        if p < gen_params.const_proba then
            FunctionDna.Const (gen_params.const_generator ())
        else
            FunctionDna.X
    )
    else
    (
        let p_bin = gen_params.bin_proba in
        let p_un = p_bin +. gen_params.un_proba in
        let p_const = p_un +. gen_params.const_proba in

        let p = Random.float 1. in

        if p < p_bin then
            let name, operation = random_op gen_params.bin_op in
            FunctionDna.BinOp (name, operation, (create_random_grow gen_params (max_depth - 1)), (create_random_grow gen_params (max_depth - 1)) )
        else if p < p_un then
            let name, operation = random_op gen_params.un_op in
            FunctionDna.UnOp (name, operation, (create_random_grow gen_params (max_depth - 1)))
        else if p < p_const then
            FunctionDna.Const (gen_params.const_generator ())
        else
            FunctionDna.X
    )
;;


(** Randomly generate a new individual who has a depth of exactly max_depth (for all branches) *)
let rec create_random_fill gen_params ~max_depth =
    if max_depth = 0 then
    (
        let p = Random.float (gen_params.const_proba +. gen_params.var_proba) in
        if p < gen_params.const_proba then
            FunctionDna.Const (gen_params.const_generator ())
        else
            FunctionDna.X
    )
    else
    (
        let p = Random.float (gen_params.un_proba +. gen_params.bin_proba) in
        if p < gen_params.bin_proba then
            let name, operation = random_op gen_params.bin_op in
            FunctionDna.BinOp (name, operation, (create_random_fill gen_params (max_depth - 1)), (create_random_fill gen_params (max_depth - 1)) )
        else
            let name, operation = random_op gen_params.un_op in
            FunctionDna.UnOp (name, operation, (create_random_fill gen_params (max_depth - 1)))
    )
;;

(** Distribute the max_depth value between min and max across the population *)
let ramped creation_fun min max ~pop_frac = creation_fun ~max_depth:(min+(int_of_float (pop_frac *. float_of_int (max-min))))

let make_pattern creation_fun json _ =
    let params = RandGenParams.read json in
    let open Yojson.Basic.Util in
    let min_depth = json |> member "min_depth" |> to_int in
    let max_depth = json |> member "max_depth" |> to_int in
    ramped (creation_fun params) min_depth max_depth
;;

let grow_pattern = make_pattern create_random_grow;;
let fill_pattern = make_pattern create_random_fill;;

let () =
    SymbolicRegressionHooks.Creation.register "grow" grow_pattern;
    SymbolicRegressionHooks.Creation.register "fill" fill_pattern
;;
