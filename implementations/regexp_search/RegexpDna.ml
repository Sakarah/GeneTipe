type t = RegexpTree.t;;
let to_string = RegexpTree.to_string;;

(* == Advanced stats == *)
let rec branch_number = function
    | RegexpTree.Concatenation (child1,child2) | RegexpTree.Alternative (child1,child2) ->
        branch_number child1 + branch_number child2
    | RegexpTree.Optional child | RegexpTree.OneOrMore child | RegexpTree.ZeroOrMore child ->
        branch_number child
    | _ -> 1
;;

let rec individual_avg_depth = function
    | RegexpTree.Concatenation (child1,child2) | RegexpTree.Alternative (child1,child2) ->
        let n1 = float_of_int (branch_number child1) in
        let n2 = float_of_int (branch_number child2) in
        1. +. (n1 *. (individual_avg_depth child1) +. n2 *. (individual_avg_depth child2)) /. (n1 +. n2)
    | RegexpTree.Optional child | RegexpTree.OneOrMore child | RegexpTree.ZeroOrMore child ->
        1. +. individual_avg_depth child
    | _ -> 1.
;;

let average_depth = Stats.average individual_avg_depth;;
let depth_diversity = Stats.diversity individual_avg_depth;;


let advanced_stats =
[
    ("Average depth", average_depth);
    ("Depth diversity", depth_diversity);
];;
