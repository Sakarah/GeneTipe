let best_individual cmp population =
    let size = Array.length population in
    let best = ref 0 in
    for i = 0 to (size - 1) do
        if cmp (fst population.(i)) (fst population.(!best)) > 0 then best := i
    done;
    population.(!best)
;;

let average val_func population =
    let size = Array.length population in
    let sum = ref 0. in
    for i = 0 to (size - 1) do
        sum := !sum +. val_func (population.(i))
    done;
    !sum /. float_of_int size
;;

let variance val_func population =
    let pop_size = Array.length population in
    let sum = ref 0.
    and sum_square = ref 0. in

    for i = 0 to (pop_size - 1) do
    (
        let v = val_func (population.(i)) in
        sum := !sum +. v;
        sum_square := !sum_square +. v *. v
    )
    done;

    let expectation = !sum /. float_of_int(pop_size) in
    let expectation_square = !sum_square /. float_of_int(pop_size) in
    expectation_square -. expectation *. expectation
;;

let diversity val_func population =
    let var = variance val_func population in
    1. -. 1./.(1. +. var)
;;

module type Printer =
sig
    type individual
    type fitness
    val print_stats : (fitness * individual) array -> unit
    val print_advanced_stats : (fitness * individual) array -> unit
    val print_population : (fitness * individual) array -> unit
end;;

module MakePrinter (Individual : EvolParams.Individual) (Fitness : EvolParams.Fitness) =
struct
    let print_individual (fitness, individual) =
        Printf.printf "%s ~ %s\n" (Fitness.to_string fitness) (Individual.to_string individual)
    ;;

    let print_stats population =
        (try
            let average_fitness = average (function (fit,_) -> Fitness.to_float fit) population in
            Printf.printf "Average fitness : %e\n" average_fitness
        with Invalid_argument _ -> ());
        Printf.printf "Best individual :\n";
        print_individual (best_individual Fitness.compare population);
    ;;

    let print_advanced_stats population =
        let individuals = Array.map (function (_,ind) -> ind) population in
        let print_stat (stat_name, stat_fun) =
            Printf.printf "%s : %f\n" stat_name (stat_fun individuals)
        in
        List.iter print_stat Individual.advanced_stats
    ;;

    let print_population = Array.iter print_individual;;
end
