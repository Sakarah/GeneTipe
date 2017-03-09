(** This fitness function is using a combination of 3 factors to give a fitness to an individual.
    It combines the scores of a partial and a full match fitness with a score decreasing with the size of the regular expression.
    The length is counted negatively : shorter regexp are better. *)
let fitness full_match_factor partial_match_factor size_factor (examples,counter_examples) regexp =
    let automata = RegexpAutomata.from_tree regexp in
    let example_score = ref 0. in

    let rec longest_interval = function
        | [] -> 0
        | (s,e)::t -> max (e-s) (longest_interval t)
    in
    let compute_example_substring_score ex =
        let matching_substrings = RegexpAutomata.matching_substrings automata ex in
        let partial_match_score = float_of_int (longest_interval matching_substrings) /. float_of_int (String.length ex) in
        let full_match_score = if RegexpAutomata.is_matching automata ex then 1. else 0. in
        (partial_match_factor *. partial_match_score) +. (full_match_factor *. full_match_score)
    in

    Array.iter (function ex -> example_score := !example_score +. (compute_example_substring_score ex)) examples;
    Array.iter (function ex -> example_score := !example_score -. (compute_example_substring_score ex)) counter_examples;

    let size_score = float_of_int (RegexpTree.size regexp) in
    !example_score -. (size_factor *. size_score)
;;

let make_fitness json =
    let open Yojson.Basic.Util in
    let full_match_factor = json |> member "full_match_factor" |> to_float in
    let partial_match_factor = json |> member "partial_match_factor" |> to_float in
    let size_factor = json |> member "size_factor" |> to_float in
    fitness full_match_factor partial_match_factor size_factor
;;

let () =
    RegexpSearchHooks.Fitness.register "multiobjective" make_fitness
;;

