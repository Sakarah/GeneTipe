(** Simplifies a function evaluating all constants. 
    e.g. cos(3.14) -> 1.00 *)
let rec simplify = function
    | Dna.UnOp (name,op,child) ->
    (
        let new_child = simplify child in
        match new_child with 
            | Dna.Const(a) -> Dna.Const(op a)
            | _ -> Dna.UnOp (name,op,new_child)
    )
    | Dna.BinOp (name,op,child1,child2) ->
    (
        let t1 = simplify child1 in
        let t2 = simplify child2 in
        match t1,t2 with 
            | Dna.Const a, Dna.Const b -> Dna.Const(op a b)
            | _ -> Dna.BinOp (name,op,t1,t2)
    )
    | Dna.X -> Dna.X
    | Dna.Const a -> Dna.Const a
;;

let eval_const _ = simplify;;

let () =
    Plugin.Simplification.register "eval_const" eval_const
;;
