(** This fitness function count the number of full match for examples and the number of non full match for counter-examples.
    It then mixes the two according to the parameters. Each true positive or false positive will increase the fitness value.
    This very basic function will illustrate the fact that we need a fitness function that reflects little improvements. *)

let build_full_match_fitness json =
    let open Yojson.Basic.Util in
    let true_positive_score = json |> member "full_example_score" |> to_float in
    let true_negative_score = json |> member "full_counter_example_score" |> to_float in
    let elim_size = json |> member "elim_size" |> to_int in

    (module struct
        type t = float*float;; (** The fitness value contains in order, the proportion of true positive and the proportion of true negative *)

        type individual = RegexpTree.t
        type target_data = ExampleList.t

        let to_float (tpos,tneg) = (tpos *. true_positive_score) +. (tneg *. true_negative_score);;

        let to_string (tpos,tneg) =
            Printf.sprintf "%.4f (%.2f%%+ %.2f%%-)" (to_float (tpos,tneg)) (100. *. tpos) (100. *. tneg)
        ;;

        let compare x y = Pervasives.compare (to_float x) (to_float y);;

        let compute (examples,counter_examples) regexp =
            if RegexpTree.size regexp > elim_size then (0., 0.)
            else
            (
                let automata = RegexpAutomata.from_tree regexp in

                let true_positive = ref 0 in
                let incrIfMatch ex =
                    if RegexpAutomata.is_matching automata ex then
                        incr true_positive
                in
                Array.iter incrIfMatch examples;

                let true_negative = ref 0 in
                let incrIfNotMatch ex =
                    if not (RegexpAutomata.is_matching automata ex) then
                        incr true_negative
                in
                Array.iter incrIfNotMatch counter_examples;

                (float_of_int !true_positive /. float_of_int (Array.length examples),
                float_of_int !true_negative /. float_of_int (Array.length counter_examples))
            )
        ;;
    end : EvolParams.Fitness with type individual = RegexpTree.t and type target_data = ExampleList.t)
;;

let () =
    RegexpSearchHooks.Fitness.register "full_match" build_full_match_fitness
;;
