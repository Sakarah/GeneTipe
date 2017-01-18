(** This fitness function is proportional to the longest substring matched within each example over its length.
    Every counter-example is counted negatively.
    This fitness should reward small improvements on the regexp maybe making the full match less rewarding. *)
let fitness _ (examples,counter_examples) regexp =
    let automata = RegexpAutomata.from_tree regexp in
    let fitness = ref 0. in
    
    let rec longest_interval = function
        | [] -> 0
        | (s,e)::t -> max (e-s) (longest_interval t)
    in
    let compute_example_substring_score ex =
        let matching_substrings = RegexpAutomata.matching_substrings automata ex in
        float_of_int (longest_interval matching_substrings) /. float_of_int (String.length ex)
    in
    
    Array.iter (function ex -> fitness := !fitness +. (compute_example_substring_score ex)) examples;
    Array.iter (function ex -> fitness := !fitness -. (compute_example_substring_score ex)) counter_examples;
    !fitness
;;

let () =
    RegexpSearch.Fitness.register "partial_match" fitness
;;
 
