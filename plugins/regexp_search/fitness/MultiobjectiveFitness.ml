(** This fitness function is using a combination of 3 factors to give a fitness to an individual.
    It combines the scores of a partial and a full match fitness with a score decreasing with the size of the regular expression.
    The length score is computed with the formula size_score/length : shorter regexp are better. *)
let build_multiobjective_fitness json =
    let open Yojson.Basic.Util in

    let full_example_score = json |> member "full_example_score" |> to_float in
    let full_counter_example_score = json |> member "full_counter_example_score" |> to_float in
    let partial_example_score = json |> member "partial_example_score" |> to_float in
    let partial_counter_example_score = json |> member "partial_counter_example_score" |> to_float in
    let size_score = json |> member "size_score" |> to_float in
    let elim_size = json |> member "elim_size" |> to_int in

    (module struct
        type t = int*int*float*float*int;; (** The fitness value contains in order, the number of true positive, the number of true negative, the partial match value of the positive examples, the partial match value of the negative examples and the size of the regexp. *)

        type individual = RegexpTree.t
        type target_data = ExampleList.t

        let to_float (fullpos,fullneg,parpos,parneg,len) =
            if len > elim_size then 0.
            else
                (float_of_int fullpos *. full_example_score) +. (float_of_int fullneg *. full_counter_example_score) +.
                (parpos *. partial_example_score) +. (parneg *. partial_counter_example_score) +. (size_score /. (float_of_int len))
        ;;

        let to_string ((fullpos,fullneg,parpos,parneg,len) as f) =
            Printf.sprintf "%.4f (full:%d+ %d- | par:%.2f+ %.2f- | len:%d)" (to_float f) fullpos fullneg parpos parneg len
        ;;

        let compare x y = Pervasives.compare (to_float x) (to_float y);;

        let compute (examples,counter_examples) regexp =
            let automata = RegexpAutomata.from_tree regexp in

            let fullpos = ref 0 in
            let fullneg = ref 0 in
            let parpos = ref 0. in
            let parneg = ref 0. in

            let rec longest_interval = function
                | [] -> 0
                | (s,e)::t -> max (e-s) (longest_interval t)
            in

            let compute_example ex =
                let matching_substrings = RegexpAutomata.matching_substrings automata ex in
                parpos := !parpos +. (float_of_int (longest_interval matching_substrings) /. float_of_int (String.length ex));
                if RegexpAutomata.is_matching automata ex then incr fullpos
            in
            Array.iter compute_example examples;

            let compute_counter_example ex =
                let matching_substrings = RegexpAutomata.matching_substrings automata ex in
                parneg := !parneg +. 1. -. (float_of_int (longest_interval matching_substrings) /. float_of_int (String.length ex));
                if not (RegexpAutomata.is_matching automata ex) then incr fullneg
            in
            Array.iter compute_counter_example counter_examples;

            (!fullpos, !fullneg, !parpos, !parneg, RegexpTree.size regexp)
        ;;
    end : EvolParams.Fitness with type individual = RegexpTree.t and type target_data = ExampleList.t)
;;

let () =
    RegexpSearchHooks.Fitness.register "multiobjective" build_multiobjective_fitness
;;

