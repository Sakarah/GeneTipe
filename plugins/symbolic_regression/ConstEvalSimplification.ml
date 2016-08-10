(** Simplifies a function evaluating all constants. 
    e.g. cos(3.14) -> 1.00 *)
let rec simplify = function
    | FunctionDna.UnOp (name,op,child) ->
    (
        let new_child = simplify child in
        match new_child with 
            | FunctionDna.Const a -> FunctionDna.Const (op a)
            | _ -> FunctionDna.UnOp (name,op,new_child)
    )
    | FunctionDna.BinOp (name,op,child1,child2) ->
    (
        let t1 = simplify child1 in
        let t2 = simplify child2 in
        match t1,t2 with 
            | FunctionDna.Const a, FunctionDna.Const b -> FunctionDna.Const (op a b)
            | _ -> FunctionDna.BinOp (name,op,t1,t2)
    )
    | FunctionDna.X -> FunctionDna.X
    | FunctionDna.Const a -> FunctionDna.Const a
;;

let eval_const _ = simplify;;

let () =
    SymbolicRegression.Simplification.register "eval_const" eval_const
;;
