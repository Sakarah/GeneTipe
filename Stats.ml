exception Found of int;;


let best_individual population =
    let size = Array.length population in
    let max = ref 0 in
    for i = 0 to (size - 1) do
        if (fst population.(i)) > (fst population.(!max)) then max := i
    done;
    population.(!max)
;;


let pop_average val_func population =
    let size = Array.length population in
    let sum = ref 0. in
    for i = 0 to (size - 1) do
        sum := !sum +. val_func (population.(i))
    done;
    !sum /. float_of_int size
;;

let average_fitness = pop_average fst;;


let rec branch_number = function 
    | Dna.BinOp (_,_,child1,child2) -> branch_number child1 + branch_number child2
    | Dna.UnOp (_,_,child) -> branch_number child
    | _ -> 1
;;


let rec individual_avg_depth = function
    | Dna.BinOp (_,_,child1,child2) -> 
        let n1 = float_of_int (branch_number child1) in
        let n2 = float_of_int (branch_number child2) in
        1. +. (n1 *. (individual_avg_depth child1) +. n2 *. (individual_avg_depth child2)) /. (n1 +. n2)
    | Dna.UnOp (_,_,child) -> 1. +. individual_avg_depth child
    | _ -> 1.
;;

let average_depth = pop_average (function (fit,dna) -> individual_avg_depth dna);;


let operator_diversity population bin_op un_op =
    let pop_size = Array.length population in
    let operator_number = Array.length bin_op + Array.length un_op in
    let sum_operator = Array.make operator_number 0
    and sum_operator_square = Array.make operator_number 0 in
    
    let search_index op_table element = (* get the index corresponding to the operator in the array *)
        try
            let size = Array.length op_table in
            for i = 0 to (size - 1) do
                let (proba,name,f) = op_table.(i) in
                if name = element then raise (Found i)
            done;
            failwith (element^" not found")
        with Found i -> i
    in 
    
    for i = 0 to (pop_size - 1) do
    (
        let count_operator = Array.make operator_number 0 in
        
        let rec counter dna = match dna with (* get the number of each operator in the individual *)
            | Dna.BinOp (name,_, child1, child2) -> let index = search_index bin_op name in
                count_operator.(index) <- count_operator.(index) + 1;
                counter child1; counter child2
            | Dna.UnOp (name,_,child1) -> let index = search_index un_op name in
                count_operator.(index) <- count_operator.(index) + 1
            | _ -> ()
        in 

        counter (snd population.(i));
        for j = 0 to (operator_number - 1) do
        (
            let add_number = count_operator.(j) in
            sum_operator.(j) <- sum_operator.(j) + add_number;
            sum_operator_square.(j) <- sum_operator_square.(j) + add_number * add_number;
        )
        done;
    )
    done;

    let sum_variance = ref 0. in
    for i = 0 to (operator_number - 1) do
    (
		let pop_size_float = float_of_int(pop_size) in
        let expectation = float_of_int(sum_operator.(i))/. pop_size_float in
        let expectation_square = float_of_int(sum_operator_square.(i))/. pop_size_float in
        let op_variance = expectation_square -. expectation *. expectation in
        sum_variance := !sum_variance +. op_variance
    )
    done;
	
    1. -. 1./.(1. +. !sum_variance)
;;

let depth_diversity population =
	let pop_size = Array.length population in
	let sum_depth = ref 0. 
    and sum_depth_square = ref 0. in
	
	for i = 0 to (pop_size - 1) do
    (
		let d = individual_avg_depth (snd population.(i)) in
        sum_depth := !sum_depth +. d;
        sum_depth_square := !sum_depth_square +. d *. d
	)
	done;
	
	let depth_expectation = !sum_depth /. float_of_int(pop_size) in
    let depth_expectation_square = !sum_depth_square /. float_of_int(pop_size) in
    let depth_variance = depth_expectation_square -. depth_expectation *. depth_expectation in
	1. -. 1./.(1. +. depth_variance)
;;

let print_individual (fitness, dna) =
    Printf.printf "%e ~ %s\n" fitness (Dna.to_string dna)
;;

let print_stats population =
    Printf.printf "Average fitness : %e\n" (average_fitness population);
    Printf.printf "Best individual :\n";
    print_individual (best_individual population);
;;

let print_advanced_stats population bin_op un_op =
    Printf.printf "Average depth : %f\n" (average_depth population);
    Printf.printf "Genetic structure diversity : %f\n" (operator_diversity population bin_op un_op);
	Printf.printf "Depth diversity : %f\n" (depth_diversity population)
;;

let print_population = Array.iter print_individual;;
