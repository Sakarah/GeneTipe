(** This fitness function returns 1/(1+sum(diff²)) where diff is the vertical distance between a point and the curve. *)
module SquaredDiffFitness =
struct
    type t = float
    type individual = FunctionDna.t
    type target_data = (float*float) array

    let to_string fit = Printf.sprintf "%e" fit;;
    let to_float fit = fit;;
    let compare = Pervasives.compare;;

    let compute points dna =
        let n = Array.length points in
        let difference = ref 0. in
        for i = 0 to n-1 do
            let x,y = points.(i) in
            let evaluation = FunctionDna.eval dna x in
            difference := !difference +. ( evaluation -. y ) ** 2.
        done;
        if classify_float !difference = FP_nan then 0. (* nan is not equal itself... *)
        else 1. /. (1. +. !difference)
    ;;
end

let () =
    SymbolicRegressionHooks.Fitness.register "squared_diff" (function _ -> (module SquaredDiffFitness))
;;
