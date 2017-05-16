(** Select the given number of individuals by comparing pairs of individuals and keeping the best,
    and complete the winners array with left individuals if the number of kept individuals exceeds half the size of the intitial population.
    Caution: target_size mustn't be less than half the input population size in this tournament.
    This mean that you cannot use this plugin with a growth_factor over 2. *)

module TournamentMethod (Fitness : EvolParams.Fitness) =
struct
    let f initial_population ~target_size =
        let size = Array.length initial_population in
        if target_size*2 < size then failwith "Cannot use tournament with a growth_factor over 2";

        let winners = Array.make target_size initial_population.(0) in
        let n_fill_in = 2 * target_size - size in
        RandUtil.shuffle initial_population;

        (* Fill the beginning of the winners array with the first (randomly chosen) individual until the number of slots left in the winners array are exactly a half of the number of individuals left in the initial population array. *)
        for i = 0 to (n_fill_in - 1) do
            winners.(i) <- initial_population.(i)
        done;

        for i = 0 to (target_size - n_fill_in - 1) do
            if Fitness.compare (fst initial_population.(n_fill_in + 2*i)) (fst initial_population.(n_fill_in + 2*i+1)) > 0 then
                winners.(n_fill_in + i) <- initial_population.(n_fill_in + 2*i)
            else winners.(n_fill_in + i) <- initial_population.(n_fill_in + 2*i+1)
        done;
        winners
    ;;
end

let () =
    Plugin.Selection.register "tournament" (function _ -> (module TournamentMethod))
;;
