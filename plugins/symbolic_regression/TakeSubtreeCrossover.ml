let rec take_graft depth = function
    | dna when depth = 0 -> dna
    | FunctionDna.BinOp (_,_,child1,_) when Random.bool () -> take_graft (depth-1) child1
    | FunctionDna.BinOp (_,_,_,child2) -> take_graft (depth-1) child2
    | FunctionDna.UnOp (_,_,child) -> take_graft (depth-1) child
    | dna -> dna
;;

(** Generate a new individual by doing a crossover wich replace some parts of the first dna by elements of the second. *)
let take_subtree_crossover _ base giver =
    let crossover_depth = Random.int ((FunctionDna.depth base)+1) in
    let rec crossov depth = function
        | _ when depth = crossover_depth -> take_graft depth giver
        | FunctionDna.BinOp (n,f,child1,child2) when Random.bool () -> FunctionDna.BinOp (n,f,crossov (depth+1) child1,child2)
        | FunctionDna.BinOp (n,f,child1,child2) -> FunctionDna.BinOp (n,f,child1,crossov (depth+1) child2)
        | FunctionDna.UnOp (n,f,child) -> FunctionDna.UnOp (n,f,crossov (depth+1) child)
        | _ -> take_graft depth giver
    in
    crossov 0 base
;;

let () =
    SymbolicRegressionHooks.Crossover.register "take_subtree" take_subtree_crossover
;;
