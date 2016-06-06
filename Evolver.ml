type evolutionParams =
{
    max_depth : int ;
    random_gen_params : Dna.randomGenParams ;
    growth_factor : float ;
    mutation_ratio : float
};;

let init_population ~size ~max_depth rand_gen_params =
    Array.init size (function i -> (None, Dna.create_random ~max_depth:((max_depth*i)/size) rand_gen_params))
;;

let fitness points dna =
    let n = Array.length points in
    let difference = ref 0. in
    for i = 0 to n-1 do
        let x,y = points.(i) in
        let evaluation = Dna.eval x dna in
        difference := !difference +. ( evaluation -. y ) ** 2.
    done;
    if classify_float !difference = FP_nan then 0. (* nan is not equal itself... *)
    else 1. /. (1. +. !difference)
;;

let compute_fitness points =
    let fillFitness = function
        | (None,dna) -> (fitness points dna, dna)
        | (Some fitness,dna) -> (fitness, dna)
    in Array.map fillFitness
;;

let shuffle initial_population =
    let size = Array.length initial_population in
    for i=0 to (size-2) do
        let invPos = i + 1 + Random.int (size-i-1) in
        let switch = initial_population.(i) in
        initial_population.(i) <- initial_population.(invPos);
        initial_population.(invPos) <- switch
    done
;;

let tournament initial_population ~target_size =
    let size = Array.length initial_population in
    let winners = Array.make target_size initial_population.(0) in
    let n_fill_in = 2* target_size - size in
    shuffle initial_population;
    for i = 0 to (n_fill_in - 1) do
        winners.(i) <- initial_population.(i)
    done;
    for i = 0 to (target_size - n_fill_in - 1) do
        if (fst initial_population.(n_fill_in + 2*i)) > (fst initial_population.(n_fill_in + 2*i+1)) then
            winners.(n_fill_in + i) <- initial_population.(n_fill_in + 2*i)
        else winners.(n_fill_in + i) <- initial_population.(n_fill_in + 2*i+1)
    done;
    winners
;;

let tournament_by_packs population ~target_size =
	let pop_size = Array.length population in
	let pack_size = int_of_float(ceil (float_of_int(pop_size)/.float_of_int(target_size))) in
	let selected_dna = Array.make target_size population.(0) in
	shuffle population;
	for i = 0 to (target_size - 1) do
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
	selected_dna
;;

let reproduce initial_population evolution_params =
    let pop_size = Array.length initial_population in
    let fitness_total = ref 0. in
    let fitness_cumul = Array.init pop_size (function i -> fitness_total := !fitness_total +. (fst initial_population.(i)); !fitness_total) in

    let target_size = int_of_float(float_of_int pop_size *. evolution_params.growth_factor) in
    let target_population = Array.make target_size (None, snd initial_population.(0)) in

    (* Copy the previous individuals in the target population *)
    for i = 0 to pop_size-1 do
        let (fitness,dna) = initial_population.(i) in
        target_population.(i) <- (Some fitness, dna)
    done;

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
        snd initial_population.(first_above 0 pop_size)
    in

    (* The rest of the array is filled with generated offsprings *)
    for i = pop_size to target_size - 1 do
        let parent_dna = individual_from_rand (Random.float !fitness_total) in
        let modif_depth = Random.int evolution_params.max_depth in
        if evolution_params.mutation_ratio < Random.float 1. then
            target_population.(i) <- (None, Dna.mutation ~mutation_depth:modif_depth ~max_depth:evolution_params.max_depth evolution_params.random_gen_params parent_dna)
        else
            let second_parent_dna = individual_from_rand (Random.float !fitness_total) in
            target_population.(i) <- (None, Dna.crossover ~crossover_depth:modif_depth parent_dna second_parent_dna)
    done;
    target_population
;;

let evolve points evolution_params initial_population =
    let pop_size = Array.length initial_population in
    let child_population = reproduce initial_population evolution_params in
    let evaluated_population = compute_fitness points child_population in
    tournament evaluated_population ~target_size:pop_size
;;
