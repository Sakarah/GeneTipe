let () =
    let pop_size = ref 100 in
    let max_depth = ref 5 in
    let generations = ref 100 in
    let verbosity = ref 2 in

    let spec_list =
    [
        ("--pop", Arg.Set_int pop_size, "Set the population size (deafult is 100)");
        ("-p", Arg.Set_int pop_size, "Shorthand for --pop");
        ("--gen", Arg.Set_int generations, "Set the number of generations (default is 100)");
        ("-g", Arg.Set_int generations, "Shorthand for --gen");
        ("--depth", Arg.Set_int max_depth, "Set the maximum depth of an individual (default is 5)");
        ("-d", Arg.Set_int max_depth, "Shorthand for --depth");
        ("--rand", Arg.Int (function r -> Random.init r), "Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "Shorthand for --rand");
        ("--quiet", Arg.Unit (fun () -> verbosity := 0), "Do not show anything else than the result (equivalent to -v 0)");
        ("--no-stats", Arg.Unit (fun () -> verbosity := 1), "No intermediate statistics about the currently generated population (equivalent to -v 1)");
        ("--full-stats", Arg.Unit (fun () -> verbosity := 3), "Print full statistics about the currently generated population (equivalent to -v 3)");
        ("-v", Arg.Set_int verbosity, "Set the verbosity level (default is 2). Lower values speed up the process");
    ]
    in

    let usage_msg =
        "GeneTipe is a symbolic regression tool.\n" ^
        "It automatically build a function matching the points given using a genetic algorithm.\n" ^
        "The program waits as input the number of sampling points on the first line and then on each line the x and y coordinates of a point separated by a space.\n\n" ^
        "Options available:"
    in

    Arg.parse spec_list (fun _ -> raise (Arg.Bad "Unexpected anonymous argument")) usage_msg;

    let nb_points = Scanf.scanf "%d\n" (function n -> n) in

    let points = Array.make nb_points (0.,0.) in
    for i = 0 to nb_points-1 do
        points.(i) <- Scanf.scanf "%f %f\n" (fun x y -> (x,y))
    done;

    if !verbosity >= 1 then Printf.printf "Initialize the population with %d individuals\n" !pop_size;
    let gen_params = Parameters.rand_gen_params in
    let evo_params = Parameters.evolution_params !max_depth gen_params in
    let init_pop = Evolver.init_population ~size:!pop_size ~max_depth:!max_depth gen_params in
    let pop = ref (Evolver.compute_fitness points init_pop) in
    if !verbosity >= 1 then Stats.print_population !pop;

    Sys.catch_break true; (* If you do a Ctrl+C you still have the results *)
    (try
        for g = 1 to !generations do
            if !verbosity >= 1 then Printf.printf "- Generation %d -\n%!" g;
            pop := Evolver.evolve points evo_params !pop;
            if !verbosity >= 2 then Stats.print_stats !pop;
            if !verbosity >= 3 then Stats.print_advanced_stats !pop gen_params.Dna.bin_op gen_params.Dna.un_op
        done
    with Sys.Break -> ());

    pop := Evolver.simplify_individuals !pop;
    if !verbosity >= 1 then
    (
        Printf.printf "= End of evolution =\n";
        Stats.print_population !pop;
        Printf.printf "= Final stats =\n";
        Stats.print_stats !pop;
        Stats.print_advanced_stats !pop gen_params.Dna.bin_op gen_params.Dna.un_op
    )
    else
    (
        let bestFitness, bestDna = Stats.best_individual !pop in
        Printf.printf "%f\n%s" bestFitness (Dna.to_string bestDna)
    )
;;
