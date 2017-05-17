(** Generate a new individual by skipping a path in the regexp that could be already skipped.
    This can reduce the language recognized by the regexp and should simplify it. *)
let reduce_mutation _ _ base =
    let rec reduce depth regexp_tree =
        let mod_right = Random.bool () in
        match regexp_tree with
            | RegexpTree.Concatenation (RegexpTree.Optional _,b) when depth <= 1 && mod_right -> b
            | RegexpTree.Concatenation (RegexpTree.ZeroOrMore _,b) when depth <= 1 && mod_right -> b
            | RegexpTree.Concatenation (a,b) when mod_right -> RegexpTree.Concatenation (reduce (depth-1) a, b)
            | RegexpTree.Concatenation (a,RegexpTree.Optional _) when depth <= 1 -> a
            | RegexpTree.Concatenation (a,RegexpTree.ZeroOrMore _) when depth <= 1 -> a
            | RegexpTree.Concatenation (a,b) -> RegexpTree.Concatenation (a, reduce (depth-1) b)
            | RegexpTree.Alternative (a,b) when depth = 0 && mod_right -> a
            | RegexpTree.Alternative (a,b) when depth = 0 -> b
            | RegexpTree.Alternative (a,b) when mod_right -> RegexpTree.Alternative (reduce (depth-1) a, b)
            | RegexpTree.Alternative (a,b) -> RegexpTree.Alternative (a, reduce (depth-1) b)
            | RegexpTree.Optional t when depth = 0 -> t
            | RegexpTree.Optional t -> RegexpTree.Optional (reduce (depth-1) t)
            | RegexpTree.OneOrMore t when depth = 0 -> t
            | RegexpTree.OneOrMore t -> RegexpTree.OneOrMore (reduce (depth-1) t)
            | RegexpTree.ZeroOrMore t when depth = 0 -> t
            | RegexpTree.ZeroOrMore t -> RegexpTree.ZeroOrMore (reduce (depth-1) t)
            | terminal_node -> terminal_node
    in

    match RegexpTree.depth base with
        | 0 -> base
        | base_depth -> reduce (Random.int base_depth) base
;;

let () =
    RegexpSearchHooks.Mutation.register "reduce" reduce_mutation
;;
