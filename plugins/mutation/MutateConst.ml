(** Generate a new individual by tweaking constants of an already existing one *)
let mutate_constants ~range ~proba ~max_depth base =
    let rec mutate = function
        | Dna.BinOp (name,func,child1,child2) -> Dna.BinOp (name, func, mutate child1, mutate child2)
        | Dna.UnOp (name,func,child) -> Dna.UnOp (name, func, mutate child)
        | Dna.Const a when Random.float 1. < proba -> Dna.Const (a +. RandUtil.uniform_float range)
        | dna -> dna
    in
    mutate base
;;

open Yojson.Basic.Util;;

let to_range json = ( json |> member "min" |> to_number, json |> member "max" |> to_number );;

let mutate_const_pattern json =
    let range = json |> member "const_range" |> to_range in
    let proba = json |> member "mutation_proba" |> to_float in
    mutate_constants ~range ~proba
;;

let () =
    Plugin.Mutation.register "mutate_const" mutate_const_pattern
;;
