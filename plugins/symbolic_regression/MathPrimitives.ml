open Yojson.Basic.Util;;

let math_bin_op json = json |> member "fun" |> to_string |> MathParser.parse_xy;;
let math_un_op json = json |> member "fun" |> to_string |> MathParser.parse_x;;

let () =
    SymbolicRegressionHooks.BinOp.register "math" math_bin_op;
    SymbolicRegressionHooks.UnOp.register "math" math_un_op
;;
