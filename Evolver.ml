exception IllFormed;;

let init_population ~size ~max_depth rand_gen_params =
    Array.init size (function _ -> (None, Dna.create_random ~max_depth rand_gen_params))
;;

let fitness points dna =
    let n = Array.length points in
    let difference = ref 0. in
    for i = 0 to n-1 do
        let x,y = points.(i) in
        let evaluation = Dna.eval x dna in
        if evaluation = nan || evaluation = infinity then raise IllFormed;
        difference := !difference +. ( evaluation -. y ) ** 2.
    done;
    !difference
;;

let compute_fitness points = 
    let fillFitness = function
        | (None,dna) -> (fitness points dna, dna)
        | (Some fitness,dna) -> (fitness, dna)
    in Array.map fillFitness
;;
        
let shuffle initialPopulation =
    let size = Array.length initialPopulation in
    for i=0 to (size-2) do
        let invPos = i + 1 + Random.int (size-i-1) in
        let switch = initialPopulation.(i) in 
        initialPopulation.(i) <- initialPopulation.(invPos);
        initialPopulation.(invPos) <- switch
    done
;;

let tournament initialPopulation ~target_size = (* target_size is the size of winners, it mustn't be > size *)
	let size = Array.length initialPopulation in
	let winners = Array.make target_size initialPopulation.(0) in
	let n_fill_in = 2* target_size - size in
    shuffle initialPopulation;
	for i = 0 to (n_fill_in - 1) do
		winners.(i) <- initialPopulation.(i)
	done;
    for i = 0 to (target_size - n_fill_in - 1) do
        if (fst initialPopulation.(n_fill_in + 2*i)) > (fst initialPopulation.(n_fill_in + 2*i+1)) then
        winners.(n_fill_in + i) <- initialPopulation.(n_fill_in + 2*i)
        else winners.(n_fill_in + i) <- initialPopulation.(n_fill_in + 2*i + 1)
    done;
    winners
;;

let reproduce initialPopulation =
    [||] (* Sakarah *)
;;

let evolve initialPopulation ~generations =
    initialPopulation (* Gabzcr ? *)
;;