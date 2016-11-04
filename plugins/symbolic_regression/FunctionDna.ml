type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X
;;

(* == Evaluation and printing == *)
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

let to_string dna =
    let rec to_string_impl ~bracket = function
        | Const a -> Printf.sprintf "%.2f" a
        | X -> "x"
        | UnOp (name,_,child) -> name ^ "(" ^ (to_string_impl ~bracket:false child) ^ ")"
        | BinOp (symb,_,child1,child2) ->
            if bracket then "(" ^ (to_string_impl ~bracket:true child1) ^ symb ^ (to_string_impl ~bracket:true child2) ^ ")"
            else (to_string_impl ~bracket:true child1) ^ symb ^ (to_string_impl ~bracket:true child2)
    in
    to_string_impl ~bracket:false dna
;;

let print ppf dna = Format.fprintf ppf "%s" (to_string dna);;

let plot dna = Plot.plot_fun ~color:Graphics.blue (eval dna)

(* == Advanced stats == *)
let rec branch_number = function
    | BinOp (_,_,child1,child2) -> branch_number child1 + branch_number child2
    | UnOp (_,_,child) -> branch_number child
    | _ -> 1
;;

let rec individual_avg_depth = function
    | BinOp (_,_,child1,child2) ->
        let n1 = float_of_int (branch_number child1) in
        let n2 = float_of_int (branch_number child2) in
        1. +. (n1 *. (individual_avg_depth child1) +. n2 *. (individual_avg_depth child2)) /. (n1 +. n2)
    | UnOp (_,_,child) -> 1. +. individual_avg_depth child
    | _ -> 1.
;;

let average_depth = Stats.average (function (fit,dna) -> individual_avg_depth dna);;
let depth_diversity = Stats.diversity (function (fit,dna) -> individual_avg_depth dna);;

exception Found of int;;

let operator_diversity population =
    let pop_size = Array.length population in
    let operators_list = ref [] in

    let build_op population =
        let rec find_op dna l = match dna with
            | BinOp (name,_,child1,child2) -> if not(List.mem name l) then name::(find_op child1 (name::l)) @ (find_op child2 (name::l))
                else (find_op child1 (name::l)) @ (find_op child2 (name::l))
            | UnOp (name,_,child) -> if not(List.mem name l) then name::(find_op child (name::l))
                else (find_op child (name::l))
            | _ -> []
        in
        for i = 0 to (pop_size - 1) do
            operators_list := (!operators_list)@(find_op (snd population.(i)) [])
        done;
    in
    build_op population;

    let operator_number = List.length !operators_list in
    let sum_operator = Array.make operator_number 0
    and sum_operator_square = Array.make operator_number 0 in
    let operators = Array.make operator_number "" in

    let rec make_op_array index = function
        | [] -> ()
        | op::t -> operators.(index) <- op; make_op_array (index + 1) t
    in
    make_op_array 0 !operators_list;

    let search_index op_table element = (* get the index corresponding to the operator in the array *)
        try
            let size = Array.length op_table in
            for i = 0 to (size - 1) do
                let name = op_table.(i) in
                if name = element then raise (Found i)
            done;
            failwith (element^" not found")
        with Found i -> i
    in

    for i = 0 to (pop_size - 1) do
    (
        let count_operator = Array.make operator_number 0 in

        let rec counter dna = match dna with (* get the number of each operator in the individual *)
            | BinOp (name,_, child1, child2) ->
                let index = (search_index operators name) in
                count_operator.(index) <- count_operator.(index) + 1;
                counter child1; counter child2
            | UnOp (name,_,child1) ->
                let index = search_index operators name in
                count_operator.(index) <- count_operator.(index) + 1
            | _ -> ()
        in

        counter (snd population.(i));
        for j = 0 to (operator_number - 1) do
        (
            let add_number = count_operator.(j) in
            sum_operator.(j) <- sum_operator.(j) + add_number;
            sum_operator_square.(j) <- sum_operator_square.(j) + add_number * add_number;
        )
        done;
    )
    done;

    let sum_variance = ref 0. in
    for i = 0 to (operator_number - 1) do
    (
        let pop_size_float = float_of_int(pop_size) in
        let expectation = float_of_int(sum_operator.(i))/. pop_size_float in
        let expectation_square = float_of_int(sum_operator_square.(i))/. pop_size_float in
        let op_variance = expectation_square -. expectation *. expectation in
        sum_variance := !sum_variance +. op_variance
    )
    done;

    1. -. 1./.(1. +. !sum_variance)
;;

let advanced_stats =
[
    ("Average depth", average_depth);
    ("Depth diversity", depth_diversity);
    ("Operator diversity", operator_diversity)
];;
