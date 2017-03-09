(** Simplifies a regexp tree by grouping nested repetition operators.
    Ex : ?? -> ?, ?+ -> *, *+ -> *, etc *)
let rec simplify = function
    | RegexpTree.Concatenation (a,b) -> RegexpTree.Concatenation (simplify a, simplify b)
    | RegexpTree.Alternative (a,b) -> RegexpTree.Alternative (simplify a, simplify b)
    | RegexpTree.Optional child ->
        let newChild = simplify child in
        ( match newChild with
            | RegexpTree.Optional a -> RegexpTree.Optional a
            | RegexpTree.OneOrMore a -> RegexpTree.ZeroOrMore a
            | RegexpTree.ZeroOrMore a -> RegexpTree.ZeroOrMore a
            | _ -> RegexpTree.Optional newChild
        )
    | RegexpTree.OneOrMore child ->
        let newChild = simplify child in
        ( match newChild with
            | RegexpTree.Optional a -> RegexpTree.ZeroOrMore a
            | RegexpTree.OneOrMore a -> RegexpTree.OneOrMore a
            | RegexpTree.ZeroOrMore a -> RegexpTree.ZeroOrMore a
            | _ -> RegexpTree.OneOrMore newChild
        )
    | RegexpTree.ZeroOrMore child ->
        let newChild = simplify child in
        ( match newChild with
            | RegexpTree.Optional a | RegexpTree.OneOrMore a | RegexpTree.ZeroOrMore a -> RegexpTree.ZeroOrMore a
            | _ -> RegexpTree.ZeroOrMore newChild
        )
    | other -> other
;;

let repeat_simplification _ = simplify;;

let () =
    RegexpSearchHooks.Simplification.register "repeat_simplification" repeat_simplification
;;
