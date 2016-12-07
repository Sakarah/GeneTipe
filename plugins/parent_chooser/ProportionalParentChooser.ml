(** Selection method that randomly pick a parent with a probability proportional with its fitness. *)
module ProportionalParentChooserFunction =
struct
    let f population =
        let pop_size = Array.length population in
        let fitness_total = ref 0. in
        let fitness_cumul = Array.init pop_size (function i -> fitness_total := !fitness_total +. (fst population.(i)); !fitness_total) in

        (* Return the individual matching with the random number according to their fitness (more chances to get better graded ones) *)
        let individual_from_rand value =
            (* Return the index of the first cumulative fitness above value *)
            let rec first_above i j = (* i included j excluded convention *)
                if i=j then i
                else
                (
                    let k = (i+j)/2 in
                    if fitness_cumul.(k) < value then
                        first_above (k+1) j
                    else
                        first_above i k
                )
            in
            snd population.(first_above 0 pop_size)
        in

        function () -> individual_from_rand (Random.float !fitness_total)
    ;;
end

let () =
    Plugin.ParentChooser.register "proportional" (function _ -> (module ProportionalParentChooserFunction))
;;
