(** Select the individuals to be copied for the next generation by organizing fights between random packs of individuals *)

module TournamentByPacksMethod (Fitness : EvolParams.Fitness) =
struct
    let f population ~target_size =
        let pop_size = Array.length population in
        let pack_size = int_of_float(ceil (float_of_int(pop_size)/.float_of_int(target_size))) in
        let winners = Array.make target_size population.(0) in
        RandUtil.shuffle population;

        for i = 0 to (target_size - 2) do (* the last pack might be uncomplete hence target_size - 2 *)
            let index = pack_size * i in
            let selected_index = ref index in
            for j = 1 to pack_size do (* find the best individual in the pack *)
                if Fitness.compare (fst population.(index + j)) (fst population.(!selected_index)) > 0 then
                (
                    selected_index := index + j
                )
            done;
            winners.(i) <- population.(!selected_index)
        done;

        (* dealing with the last potentially uncomplete pack *)
        let index = pack_size * (target_size - 1) in
        let selected_index = ref index in
        for j = 0 to (pop_size - pack_size * (target_size - 1) - 1)  do
            if Fitness.compare (fst population.(index + j)) (fst population.(!selected_index)) > 0 then
            (
                selected_index := index + j
            )
        done;
        winners.(target_size - 1) <- population.(!selected_index);

        winners
    ;;
end

let () =
    Plugin.Selection.register "tournament_by_packs" (function _ -> (module TournamentByPacksMethod))
;;
