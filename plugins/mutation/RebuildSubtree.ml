(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics.
    The new genes added are taken in order to ensure that max_depth is never exceeded. *)
let mutation ~build_patterns ~max_depth base =
    let new_subtree ~max_depth =
        RandUtil.from_proba_list build_patterns ~max_depth
    in
    
    let mutation_depth = Random.int ((Dna.depth base)+1) in
    let rec mutate depth = function
        | _ when depth = mutation_depth -> new_subtree ~max_depth:(max_depth-mutation_depth)
        | Dna.BinOp (n,f,child1,child2) when Random.bool () -> Dna.BinOp (n,f,mutate (depth+1) child1,child2)
        | Dna.BinOp (n,f,child1,child2) -> Dna.BinOp (n,f,child1,mutate (depth+1) child2)
        | Dna.UnOp (n,f,child) -> Dna.UnOp (n,f,mutate (depth+1) child)
        | _ -> new_subtree ~max_depth:(max_depth-depth)
    in
    mutate 0 base
;;

open Yojson.Basic.Util;;

let get_params = function
    | `String name -> member name (ParamReader.get_json ())
    | json -> json
;;

let get_build_pattern pattern_json =
    let proba = pattern_json |> member "proba" |> to_float in
    let method_name = pattern_json |> member "method" |> to_string in
    let params = pattern_json |> member "params" |> get_params in
    (proba, Plugin.Creation.get method_name params)
;;

let rebuild_subtree_pattern json =
    let build_patterns = json |> to_list |> List.map get_build_pattern in
    mutation ~build_patterns
;;

let () =
    Plugin.Mutation.register "rebuild_subtree" rebuild_subtree_pattern
;;
