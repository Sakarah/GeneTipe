(** This fitness function returns 1/(1+sum(diff²)) where diff is the vertical distance between a point and the curve.
It also takes the depth of the functions into consideration. *)

let build_AdjustedSquaredDiffFitness json =
    let open Yojson.Basic.Util in
    let dim = json |> member "lessen_depth_impact" |> to_float in

    (module struct
    type t = float
    type individual = FunctionDna.t
    type target_data = (float*float) array

    let to_string fit = Printf.sprintf "%e" fit;;
    let to_float fit = fit;;
    let compare = Pervasives.compare;;

    open Yojson.Basic.Util;;

    let compute points dna =
        let n = Array.length points in
        let difference = ref 0. in
        for i = 0 to n-1 do
            let x,y = points.(i) in
            let evaluation = FunctionDna.eval dna x in
            difference := !difference +. ( evaluation -. y ) ** 2.
        done;
        if classify_float !difference = FP_nan then 0. (* nan is not equal itself... *)
        else (1. /. (1. +. !difference +. float_of_int (FunctionDna.depth dna)/.dim))
    ;;
end : EvolParams.Fitness with type individual = FunctionDna.t and type target_data = (float*float) array)
;;

let () =
    SymbolicRegressionHooks.Fitness.register "adjusted_squared_diff" build_AdjustedSquaredDiffFitness
;;
