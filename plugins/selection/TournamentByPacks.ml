(** Select the individuals to be copied for the next generation by organizing fights between random packs of individuals *)

module TournamentByPacksFunction =
struct
    let f population ~target_size =
        let pop_size = Array.length population in
        let pack_size = int_of_float(ceil (float_of_int(pop_size)/.float_of_int(target_size))) in
        let selected_dna = Array.make target_size population.(0) in
        RandUtil.shuffle population;
        for i = 0 to (target_size - 2) do
            let index = pack_size * i in
            let selected_index = ref index in
            for j = 1 to pack_size do
                if fst population.(index + j) > fst population.(!selected_index) then
                (
                    selected_index := index + j
                )
            done;
            selected_dna.(i) <- population.(!selected_index)
        done;
        let index = pack_size * (target_size - 1) in
        let selected_index = ref index in
        for j = 0 to (pop_size - pack_size * (target_size - 1) - 1)  do
            if fst population.(index + j) > fst population.(!selected_index) then
                (
                    selected_index := index + j
                )
        done;
        selected_dna.(target_size - 1) <- population.(!selected_index);
        selected_dna
    ;;
end

let () =
    Plugin.Selection.register "tournament_by_packs" (function _ -> (module TournamentByPacksFunction))
;;
