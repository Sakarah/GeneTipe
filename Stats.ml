exception Found of int;;


let best_individual population =
    let size = Array.length population in
	let max = ref 0 in
	for i = 0 to (size - 1) do
		if (fst population.(i)) > (fst population.(!max)) then max := i
	done;
	population.(!max)
;;


let average_fitness population =
	let size = Array.length population in
	let sum_fitness = ref 0. in
	for i = 0 to (size - 1) do
		sum_fitness := !sum_fitness +. (fst population.(i))
	done;
	let avg = !sum_fitness /. float_of_int(size) in
	avg
;;


let rec branch_number = function 
	| Dna.BinOp (_,_,child1,child2) -> branch_number child1 +. branch_number child2
	| Dna.UnOp (_,_,child) -> branch_number child
	| _ -> 1.
;;


let rec avg_depth = function
	| Dna.BinOp (_,_,child1,child2) -> 
		let n1 = branch_number child1 and n2 = branch_number child2 in
 		1. +. (n1 *. (avg_depth child1) +. n2 *. (avg_depth child2))/. (n1 +. n2)
	| Dna.UnOp (_,_,child) -> 1. +. avg_depth child
	| _ -> 1.
;;


let search_index op_table element = (* get the index corresponding to the operator in the array *)
	try
		let size = Array.length op_table in
		for i = 0 to (size - 1) do
			let (proba,name,f) = op_table.(i) in
			if name = element then raise (Found i)
		done;
		(-1);
	with Found i -> i
;;

let genetic_diversity population bin_op un_op =
	let pop_size = Array.length population in
	let operator_number = Array.length bin_op + Array.length un_op in
	let sum_operator = Array.make operator_number 0.
	and sum_operator_square = Array.make operator_number 0.
	and sum_depth = ref 0. 
	and sum_depth_square = ref 0. in
	
	let search_index op_table element = (* get the index corresponding to the operator in the array *)
		try
			let size = Array.length op_table in
			for i = 0 to (size - 1) do
				let (proba,name,f) = op_table.(i) in
				if name = element then raise (Found i)
			done;
			(-1);
		with Found i -> i
	in 
	
	for i = 0 to (pop_size - 1) do
	(
		let count_operator = Array.make operator_number 0. in
		
		let rec counter dna = match dna with (* get the number of each operator in the individual *)
			| Dna.BinOp (name,_, child1, child2) -> let index = search_index bin_op name in
				count_operator.(index) <- count_operator.(index) +. 1.;
				counter child1; counter child2
			| Dna.UnOp (name,_,child1) -> let index = search_index un_op name in
				count_operator.(index) <- count_operator.(index) +. 1.
			| _ -> ()
		in 

		counter (snd population.(i));
		for j = 0 to (operator_number - 1) do
		(
			let add_number = count_operator.(j) in
			sum_operator.(i) <- sum_operator.(i) +. add_number;
			sum_operator_square.(i) <- sum_operator_square.(i) +. add_number *. add_number;
		)
		done;

		let d = avg_depth (snd population.(i)) in
		sum_depth := !sum_depth +. d;
		sum_depth_square := !sum_depth_square +. d *. d
	)
	done;

	let sum_variance = ref 0. in
	for i = 0 to (operator_number - 1) do
	(
		let expectation = (sum_operator.(i))/. float_of_int(operator_number)
		and expectation_square = (sum_operator_square.(i))/. float_of_int(operator_number) in
		let op_variance = expectation_square -. expectation *. expectation in
		sum_variance := !sum_variance +. op_variance
	)
	done;
	
	let depth_expectation = !sum_depth /. float_of_int(operator_number)
	and depth_expectation_square = !sum_depth_square /. float_of_int(operator_number) in
	let depth_variance = depth_expectation_square -. depth_expectation *. depth_expectation in
	sum_variance := !sum_variance +. depth_variance;
	sqrt (!sum_variance)
;;

let print_stats population =
	print_float (fst (best_individual population));
    print_string (Dna.to_string (snd (best_individual population)));
	print_float (average_fitness population);
;;

let print_population =
    Array.iter (function (fitness, dna) -> Printf.printf "%.2f%% ~ %s\n" (fitness *. 100.) (Dna.to_string dna))
;;
