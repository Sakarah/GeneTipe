type t =
| BinOp of string*(float->float->float)*t*t
| UnOp of string*(float->float)*t
| Const of float
| X
;;


let create_random ~max_depth =
    X (* Skodt <- A coder en priorité *)
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


let print dna =
    () (* Gabzcr <- Priorité *)
;;
