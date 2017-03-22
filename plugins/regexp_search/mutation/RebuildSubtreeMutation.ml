(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics.
    The new genes added are taken in order to ensure that max_depth is never exceeded. *)
let rebuild_subtree ~gen_params data ~max_depth base =
    let mutation_depth = Random.int ((RegexpTree.depth base)+1) in
    let rec mutate depth = function
        | _ when depth = mutation_depth -> RandomCreation.create_random_grow gen_params data ~max_depth:(max_depth-mutation_depth)
        | RegexpTree.Concatenation (child1,child2) when Random.bool () -> RegexpTree.Concatenation (mutate (depth+1) child1,child2)
        | RegexpTree.Concatenation (child1,child2) -> RegexpTree.Concatenation (child1,mutate (depth+1) child2)
        | RegexpTree.Alternative (child1,child2) when Random.bool () -> RegexpTree.Alternative (mutate (depth+1) child1,child2)
        | RegexpTree.Alternative (child1,child2) -> RegexpTree.Alternative (child1,mutate (depth+1) child2)
        | RegexpTree.Optional child -> RegexpTree.Optional (mutate (depth+1) child)
        | RegexpTree.OneOrMore child -> RegexpTree.OneOrMore (mutate (depth+1) child)
        | RegexpTree.ZeroOrMore child -> RegexpTree.ZeroOrMore (mutate (depth+1) child)
        | _ -> RandomCreation.create_random_grow gen_params data ~max_depth:(max_depth-depth)
    in
    mutate 0 base
;;

let rebuild_subtree_pattern json data =
    let gen_params = RandomCreation.read_params json in
    let open Yojson.Basic.Util in
    let max_depth = json |> member "max_depth" |> to_int in
    rebuild_subtree ~gen_params data ~max_depth
;;

let () =
    RegexpSearchHooks.Mutation.register "rebuild_subtree" rebuild_subtree_pattern
;;
