(** Select individual with a probability proportional to the fitness *)

module ProportionalMethod (Fitness : EvolParams.Fitness) =
struct
    let f initial_population ~target_size =
    
        let size = Array.length initial_population in
        let winners = Array.make target_size initial_population.(0) in
        
        let fitness_total = ref 0. in
        let fitness_cumul = Array.init size (function i -> fitness_total := !fitness_total +. Fitness.to_float (fst initial_population.(i)); !fitness_total) in
        
        let rec first_above value i j = (* i included j excluded convention *)
            if i=j then i
            else
            (
                let k = (i+j)/2 in
                if fitness_cumul.(k) < value then
                    first_above value (k+1) j
                else
                    first_above value i k
            )
        in
        
        for i = 0 to (target_size - 1) do
            let random_selection = Random.float !fitness_total in
            let selected = first_above random_selection 0 size in
            
            winners.(i) <- initial_population.(selected);
            
            fitness_total := !fitness_total -. Fitness.to_float(fst initial_population.(selected));
            fitness_cumul.(selected) <- fitness_cumul.(selected) -. Fitness.to_float (fst initial_population.(selected));
            for j = selected + 1 to (size - 1) do
                fitness_cumul.(j) <- fitness_cumul.(j) -. Fitness.to_float(fst initial_population.(selected))
            done;
        done;
        
        winners
    ;;
end

let () =
    Plugin.Selection.register "proportional" (function _ -> (module ProportionalMethod))
;;