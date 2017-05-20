(** Select only the best individuals *)

module ElitistMethod (Fitness : EvolParams.Fitness) =
struct
    let f initial_population ~target_size =
        let size = Array.length initial_population in
        let winners = Array.make target_size initial_population.(0) in
        Array.sort (fun (score1,_) (score2,_) -> Fitness.compare score1 score2)  initial_population;
        for i = 0 to (target_size - 1) do
            winners.(i) <- initial_population.(i)
        done;
        winners
    ;;
end

let () =
    Plugin.Selection.register "elitist" (function _ -> (module ElitistMethod))
;;