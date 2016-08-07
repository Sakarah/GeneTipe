(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics.
    The new genes added are taken in order to ensure that max_depth is never exceeded. *)
let rebuild_subtree ~gen_params ~max_depth base =
    let mutation_depth = Random.int ((Dna.depth base)+1) in
    let rec mutate depth = function
        | _ when depth = mutation_depth -> FillGrow.create_random_grow gen_params ~max_depth:(max_depth-mutation_depth)
        | Dna.BinOp (n,f,child1,child2) when Random.bool () -> Dna.BinOp (n,f,mutate (depth+1) child1,child2)
        | Dna.BinOp (n,f,child1,child2) -> Dna.BinOp (n,f,child1,mutate (depth+1) child2)
        | Dna.UnOp (n,f,child) -> Dna.UnOp (n,f,mutate (depth+1) child)
        | _ -> FillGrow.create_random_grow gen_params ~max_depth:(max_depth-depth)
    in
    mutate 0 base
;;

let rebuild_subtree_pattern json =
    let gen_params = RandGenParams.read json in
    let open Yojson.Basic.Util in
    let max_depth = json |> member "max_depth" |> to_int in
    rebuild_subtree ~gen_params ~max_depth
;;

let () =
    Plugin.Mutation.register "rebuild_subtree" rebuild_subtree_pattern
;;
