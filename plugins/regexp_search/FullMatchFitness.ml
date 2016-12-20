(** This fitness function gives one point for each full match of an example and removes one point for each match of a counter-example.
    This very basic function will illustrate the fact that we need a fitness function that reflects little improvements. *)
let fitness _ (examples,counter_examples) regexp =
    let automata = RegexpAutomata.from_tree regexp in
    let fitness = ref 0. in

    let incrIfMatch ex =
        if RegexpAutomata.is_matching automata ex then
            fitness := !fitness +. 1.
    in
    Array.iter incrIfMatch examples;

    let decrIfMatch ex =
        if RegexpAutomata.is_matching automata ex then
            fitness := !fitness -. 1.
    in
    Array.iter decrIfMatch counter_examples;

    !fitness
;;

let () =
    RegexpSearch.Fitness.register "full_match" fitness
;;
