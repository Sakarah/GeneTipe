module type S =
sig
    type individual
    type target_data
    val init_population : target_data -> (float option * individual) array
    val compute_fitness : target_data -> (float option * individual) array -> (float * individual) array
    val simplify_individuals : ?generation:int -> (float * individual) array -> (float * individual) array
    val reproduce : target_data -> (float * individual) array -> (float option * individual) array
    val select : (float * individual) array -> target_size:int -> (float * individual) array
    val remove_duplicates : target_data -> (float option * individual) array -> (float option * individual) array
    val next_generation : target_data -> (float * individual) array -> (float * individual) array
    val evolve : ?init_pop:(float option * individual) array -> nb_gen:int -> ?verbosity:int -> target_data -> (float * individual) array
end

module Make (Parameters : EvolParams.S) =
struct
    let init_population target_data =
        let create_random i =
            let pop_frac = (float_of_int i)/.(float_of_int Parameters.pop_size) in
            (None, RandUtil.from_proba_list Parameters.creation target_data ~pop_frac)
        in
        Array.init Parameters.pop_size create_random
    ;;

    let compute_fitness target_data =
        let fillFitness = function
            | (None,dna) -> (Parameters.fitness target_data dna, dna)
            | (Some fitness,dna) -> (fitness, dna)
        in
        ArrayIter.map fillFitness
    ;;

    let simplify_individuals ?generation pop =
        let apply_simplification pop (schedule,simpl) =
            match generation with
            | Some g when schedule mod g <> 0 -> pop
            | _ -> ArrayIter.map (function (fit,dna) -> (fit,simpl dna)) pop
        in
        List.fold_left apply_simplification pop Parameters.simplifications
    ;;

    let reproduce target_data initial_population =
        let pop_size = Array.length initial_population in

        let target_size = int_of_float(float_of_int pop_size *. Parameters.growth_factor) in
        let target_population = Array.make target_size (None, snd initial_population.(0)) in

        (* Copy the previous individuals in the target population *)
        for i = 0 to pop_size-1 do
            let (fitness,dna) = initial_population.(i) in
            target_population.(i) <- (Some fitness, dna)
        done;

        let parent_chooser = Parameters.parent_chooser initial_population in

        (* The rest of the array is filled with generated offsprings *)
        for i = pop_size to target_size - 1 do
            let rand_op = Random.float 1. in
            if Parameters.crossover_ratio < rand_op then
                let parent1 = parent_chooser () in
                let parent2 = parent_chooser () in
                target_population.(i) <- (None, RandUtil.from_proba_list Parameters.crossover parent1 parent2)
            else
            (
                if Parameters.mutation_ratio +. Parameters.crossover_ratio < rand_op then
                    let parent = parent_chooser () in
                    target_population.(i) <- (None, RandUtil.from_proba_list Parameters.mutation target_data parent)
                else
                    let pop_frac = (Random.float 1.) in
                    target_population.(i) <- (None, RandUtil.from_proba_list Parameters.creation target_data ~pop_frac)
            )
        done;
        target_population
    ;;

    let select = Parameters.selection;;

    let remove_duplicates target_data initial_population =
        let pop_size = Array.length initial_population in
        let table = Hashtbl.create pop_size in
        for i=0 to (pop_size - 1) do
            let individual = Parameters.Individual.to_string (snd initial_population.(i)) in
            if not(Hashtbl.mem table individual) then
                Hashtbl.add table individual ()
            else
            (
                let pop_frac = (Random.float 1.) in
                initial_population.(i) <- (None,RandUtil.from_proba_list Parameters.creation target_data ~pop_frac)
            )
        done;
        initial_population
    ;;

    let next_generation target_data initial_population =
        let pop_size = (Array.length initial_population) in
        let child_population = reproduce target_data initial_population in
        let filtered_population =
            if Parameters.remove_duplicates then remove_duplicates target_data child_population
            else child_population
        in
        let evaluated_population = compute_fitness target_data filtered_population in
        select evaluated_population ~target_size:pop_size
    ;;

    let evolve ?init_pop ~nb_gen ?(verbosity=0) target_data =
        let module StatsPrinter = Stats.MakePrinter (Parameters.Individual) in
        let pop = ref (match init_pop with
            | Some init_pop -> compute_fitness target_data init_pop
            | None ->
                if verbosity >= 1 then Printf.printf "Initialize the population with %d individuals\n" Parameters.pop_size;
                let init_pop = init_population target_data in
                let evaluated_init_pop = compute_fitness target_data init_pop in
                if verbosity >= 2 then StatsPrinter.print_population evaluated_init_pop;
                evaluated_init_pop
            )
        in

        for generation = 1 to nb_gen do
            if verbosity >= 1 then Printf.printf "- Generation %d -\n%!" generation;
            pop := next_generation target_data !pop;
            pop := simplify_individuals ~generation !pop;
            if verbosity >= 2 then StatsPrinter.print_stats !pop;
            if verbosity >= 3 then StatsPrinter.print_advanced_stats !pop
        done;

        !pop
    ;;
end;;
