let () =
    let pop_size = ref 100 in
    let max_depth = ref 5 in
    let generations = ref 100 in

    let spec_list =
    [
        ("-p", Arg.Set_int pop_size, "Set the population size (deafult is 100)");
        ("-g", Arg.Set_int generations, "Set the number of generations (default is 100)");
        ("-d", Arg.Set_int max_depth, "Set the maximum depth of an individual (default is 5)");
        ("-r", Arg.Int (function r -> Random.init r), "Set the random seed")
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

    Printf.printf "Initialize the population with %d individuals\n" !pop_size;
    let gen_params = Parameters.rand_gen_params in
    let evo_params = Parameters.evolution_params !max_depth gen_params in
    let init_pop = Evolver.init_population ~size:!pop_size ~max_depth:!max_depth gen_params in
    let pop = ref (Evolver.compute_fitness points init_pop) in
    Stats.print_population !pop;

    Sys.catch_break true; (* If you do a Ctrl+C you still have the results *)
    (try
        for g = 1 to !generations do
            Printf.printf "- Generation %d -\n%!" g;
            pop := Evolver.evolve points evo_params !pop;
            Stats.print_stats !pop
        done
    with Sys.Break -> ());

    Printf.printf "= End of evolution =\n";
    Stats.print_population !pop
;;
