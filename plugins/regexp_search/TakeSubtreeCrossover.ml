(** Take a subtree at a given depth from the tree in the last argument.
    If it is impossible to get deep enough, just take a terminal node as the subtree. *)
let rec take_graft depth = function
    | dna when depth = 0 -> dna
    | RegexpTree.Concatenation (child1,child2) | RegexpTree.Alternative (child1,child2) ->
        if Random.bool () then
            take_graft (depth-1) child1
        else
            take_graft (depth-1) child2
    | RegexpTree.Optional child | RegexpTree.OneOrMore child | RegexpTree.ZeroOrMore child ->
        take_graft (depth-1) child
    | dna -> dna
;;

(** Perform a crossover by replacing a subtree of one given individual by another taken from the second individual. *)
let take_subtree_crossover _ base giver =
    let crossover_depth = Random.int ((RegexpTree.depth base)+1) in
    let rec crossov depth = function
        | _ when depth = crossover_depth -> take_graft depth giver
        | RegexpTree.Concatenation (child1,child2) when Random.bool () ->
            RegexpTree.Concatenation (crossov (depth+1) child1,child2)
        | RegexpTree.Concatenation (child1,child2) ->
            RegexpTree.Concatenation (child1,crossov (depth+1) child2)
        | RegexpTree.Alternative (child1,child2) when Random.bool () ->
            RegexpTree.Alternative (crossov (depth+1) child1,child2)
        | RegexpTree.Alternative (child1,child2) ->
            RegexpTree.Alternative (child1,crossov (depth+1) child2)
        | RegexpTree.Optional child -> RegexpTree.Optional (crossov (depth+1) child)
        | RegexpTree.OneOrMore child -> RegexpTree.OneOrMore (crossov (depth+1) child)
        | RegexpTree.ZeroOrMore child -> RegexpTree.ZeroOrMore (crossov (depth+1) child)
        | _ -> take_graft depth giver
    in
    crossov 0 base
;;

let () =
    RegexpSearch.Crossover.register "take_subtree" take_subtree_crossover
;;
