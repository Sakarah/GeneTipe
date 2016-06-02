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

let tournament initialPopulation =
    let size = Array.length initialPopulation in
    shuffle initialPopulation;
    let winners = Array.make ((size+1)/2) initialPopulation.(0) in
    for i = 0 to (size/2)-1 do
        if (fst initialPopulation.(2*i)) > (fst initialPopulation.(2*i+1)) then
        winners.(i) <- initialPopulation.(2*i)
        else winners.(i) <- initialPopulation.(2*i + 1)
    done;
    if size mod 2 = 1 then winners.(size-1) <- initialPopulation.(size-1);
    winners
;;

let reproduce initialPopulation =
    [||] (* Sakarah *)
;;

let evolve initialPopulation ~generations =
    initialPopulation (* Gabzcr ? *)
;;
