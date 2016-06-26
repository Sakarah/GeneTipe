(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics.
    The new genes added are taken in order to ensure that max_depth is never exceeded. *)
let mutation _ ~max_depth base =
    let mutation_depth = Random.int ((Dna.depth base)+1) in
    let gen_patterns = (Parameters.get()).Parameters.creation in
    let rec mutate depth = function
        | _ when depth = mutation_depth -> Dna.create_random gen_patterns ~max_depth:(max_depth-mutation_depth)
        | Dna.BinOp (n,f,child1,child2) when Random.bool () -> Dna.BinOp (n,f,mutate (depth+1) child1,child2)
        | Dna.BinOp (n,f,child1,child2) -> Dna.BinOp (n,f,child1,mutate (depth+1) child2)
        | Dna.UnOp (n,f,child) -> Dna.UnOp (n,f,mutate (depth+1) child)
        | _ -> Dna.create_random gen_patterns ~max_depth:(max_depth-depth)
    in
    mutate 0 base
;;

let () =
    Plugin.Mutation.register "rebuild_subtree" mutation
;;
