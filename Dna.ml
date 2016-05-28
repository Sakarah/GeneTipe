type dna =
| BinOp of string*(float->float->float)*dna*dna
| UnOp of string*(float->float)*dna
| Const of float
| X
;;


let create_random ~max_depth =
    X (* Gabzcr <- A coder en priorité *)
;;


let take_dna max_depth =
    X (* Sakarah *)
;;

let crossover ~law ~max_depth base giver =
    X (* Sakarah *)
;;

let mutation ~law ~max_depth base =
    X (* Sakarah *)
;;

let eval dna x =
    0.0 (* Skodt *)
;;

let rec print_dna = function
	|Const a -> print_float(a)
	|x -> print_char(`x`)
	|UnOp (name,_,child) -> print_string name ; print_string("("); print_dna child; print_string(")")
	|BinOp (name,_,child1, child2) -> print_string("(");  print_dna child1; print_string(")"); print_string name; print_string("("); print_dna child2; print_string(")")
;;
;;
