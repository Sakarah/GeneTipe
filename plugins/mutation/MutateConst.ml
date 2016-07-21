(** Generate a new individual by tweaking constants of an already existing one *)
let mutate_constants ~const_generator ~proba ~max_depth base =
    let rec mutate = function
        | Dna.BinOp (name,func,child1,child2) -> Dna.BinOp (name, func, mutate child1, mutate child2)
        | Dna.UnOp (name,func,child) -> Dna.UnOp (name, func, mutate child)
        | Dna.Const a when Random.float 1. < proba -> Dna.Const (a +. const_generator ())
        | dna -> dna
    in
    mutate base
;;

open Yojson.Basic.Util;;

let to_range json = ( json |> member "min" |> to_number, json |> member "max" |> to_number );;

let mutate_const_pattern json =
    let proba = json |> member "mutation_proba" |> to_float in
    let const_generator_distrib = json |> member "const_generator" |> member "distrib" |> to_string in
    let const_generator = Plugin.RandomGen.get const_generator_distrib (json |> member "const_generator" |> member "params") in
    mutate_constants ~const_generator ~proba
;;

let () =
    Plugin.Mutation.register "mutate_const" mutate_const_pattern
;;
