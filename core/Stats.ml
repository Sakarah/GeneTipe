let best_individual population =
    let size = Array.length population in
    let max = ref 0 in
    for i = 0 to (size - 1) do
        if (fst population.(i)) > (fst population.(!max)) then max := i
    done;
    population.(!max)
;;


let average val_func population =
    let size = Array.length population in
    let sum = ref 0. in
    for i = 0 to (size - 1) do
        sum := !sum +. val_func (population.(i))
    done;
    !sum /. float_of_int size
;;

let average_fitness population = average fst population;;

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
    val print_stats : (float * individual) array -> unit
    val print_advanced_stats : (float * individual) array -> unit
    val print_population : (float * individual) array -> unit
end;;

module MakePrinter (Individual : EvolParams.Individual) =
struct
    let print_individual (fitness, individual) =
        Printf.printf "%e ~ %s\n" fitness (Individual.to_string individual)
    ;;

    let print_stats population =
        Printf.printf "Average fitness : %e\n" (average_fitness population);
        Printf.printf "Best individual :\n";
        print_individual (best_individual population);
    ;;

    let print_advanced_stats population =
        let print_stat (stat_name, stat_fun) =
            Printf.printf "%s : %f\n" stat_name (stat_fun population)
        in
        List.iter print_stat Individual.advanced_stats
    ;;

    let print_population = Array.iter print_individual;;
end
