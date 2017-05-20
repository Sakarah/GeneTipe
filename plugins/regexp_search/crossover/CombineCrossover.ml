(** Perform a crossover by combining two individuals with a root node chosen between Concatenation and Alternative.
    Warning: This operation can increase the size of the resulting tree indefinitely *)
let combine_crossover ~alt_proba left right =
    if Random.float 1. < alt_proba then
        RegexpTree.Alternative (left,right)
    else
        RegexpTree.Concatenation (left,right)
;;

let build_combine_crossover json =
    let open Yojson.Basic.Util in
    let alt_proba = json |> member "alt_proba" |> to_float in
    combine_crossover ~alt_proba
;;

let () =
    RegexpSearchHooks.Crossover.register "combine" build_combine_crossover
;;

