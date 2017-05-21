(** This fitness function is proportional to the longest substring matched within each example over its length.
    Every counter-example is counted negatively : it is the non-matched characters that increase score.
    This fitness should reward small improvements on the regexp maybe making the full match less rewarding. *)
let build_partial_match_fitness json =
    let open Yojson.Basic.Util in
    let example_score = json |> member "partial_example_score" |> to_float in
    let counter_example_score = json |> member "partial_counter_example_score" |> to_float in
    let elim_size = json |> member "elim_size" |> to_int in

    (module struct
        type t = float*float;; (** The fitness value contains in order, the fitness value of the positive examples and the negative examples *)

        type individual = RegexpTree.t
        type target_data = ExampleList.t

        let to_float (pos,neg) = (pos *. example_score) +. (neg *. counter_example_score);;

        let to_string (pos,neg) =
            Printf.sprintf "%.4f (%.2f%%+ %.2f%%-)" (to_float (pos,neg)) (100. *. pos) (100. *. neg)
        ;;

        let compare x y = Pervasives.compare (to_float x) (to_float y);;

        let compute (examples,counter_examples) regexp =
            if RegexpTree.size regexp > elim_size then (0., 0.)
            else
            (
                let automata = RegexpAutomata.from_tree regexp in

                let rec longest_interval = function
                    | [] -> 0
                    | (s,e)::t -> max (e-s) (longest_interval t)
                in
                let compute_example_substring_score ex =
                    let matching_substrings = RegexpAutomata.matching_substrings automata ex in
                    float_of_int (longest_interval matching_substrings) /. float_of_int (String.length ex)
                in

                let positive_substr_match = Array.fold_left (fun score ex -> score +. (compute_example_substring_score ex)) 0. examples in
                let negative_substr_match = Array.fold_left (fun score ex -> score +. (1. -. (compute_example_substring_score ex))) 0. counter_examples in

                (positive_substr_match /. float_of_int (Array.length examples),
                negative_substr_match /. float_of_int (Array.length counter_examples))
            )
        ;;
    end : EvolParams.Fitness with type individual = RegexpTree.t and type target_data = ExampleList.t)
;;

let () =
    RegexpSearchHooks.Fitness.register "partial_match" build_partial_match_fitness
;;

