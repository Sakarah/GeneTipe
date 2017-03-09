let () =
    let generations = ref 100 in
    let config_overrides = ref [] in
    let next_overriden_key = ref "" in
    let verbosity = ref 2 in
    let show_graph = ref false in
    let config_filename = ref "" in

    let spec_list =
    [
        ("--gen", Arg.Set_int generations, "nbGen Set the number of generations (default is 100)");
        ("-g", Arg.Set_int generations, "nbGen Shorthand for --gen");
        ("--rand", Arg.Int (function r -> Random.init r), "seed Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "seed Shorthand for --rand");
        ("--pop", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "popSize Set the population size (override the config file)");
        ("-p", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "popSize Shorthand for --pop");
        ("--config-override", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            " Override a configuration value (for accessing a subkey use / separator) by a new given JSON tree. (Takes 2 parameters : the key and the new JSON value)");
        ("-c", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            " Shorthand for --config-override");
        ("--quiet", Arg.Unit (fun () -> verbosity := 0), " Do not print anything else than the best function at the end of the evolution process (equivalent to -v 0)");
        ("--no-stats", Arg.Unit (fun () -> verbosity := 1), " No intermediate statistics about the currently generated population (equivalent to -v 1)");
        ("--full-stats", Arg.Unit (fun () -> verbosity := 3), " Print full intermediate statistics about the currently generated population (equivalent to -v 3)");
        ("-v", Arg.Set_int verbosity, "verb Set the verbosity level (default is 2). Lower values speed up the process");
        ("--graph", Arg.Set show_graph, " Show a graph with the point set and the best computed function at the end")
    ]
    in

    let usage_msg =
        "Symbolic regression tool of the GeneTipe project.\n\
        It automatically build a function matching the points given using a genetic algorithm.\n\
        The program waits as input the number of sampling points on the first line and then on each line the x and y coordinates of a point separated by a space.\n\
        You need to provide it a configuration file specifying the required plugins and the parameters of the evolution process.\n\
        Usage: symbolic-regression [options] configFilename\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun cfg_file -> config_filename := cfg_file) usage_msg;
    if !config_filename = "" then raise (Arg.Bad "No config file given");

    let module ParamJson = (val ParamReader.read_json_tree ~config_overrides:!config_overrides ~filename:!config_filename) in
    let module Parameters = ParamReader.ReadConfig (SymbolicRegressionHooks) (ParamJson) in
    let module FunctionEvolver = Evolver.Make (Parameters) in
    let module StatsPrinter = Stats.MakePrinter (Parameters.Individual) in

    let nb_points = Scanf.scanf "%d\n" (function n -> n) in
    let target_points = Array.make nb_points (0.,0.) in
    for i = 0 to nb_points-1 do
        target_points.(i) <- Scanf.scanf "%f %f\n" (fun x y -> (x,y))
    done;

    let pop = FunctionEvolver.evolve ~verbosity:!verbosity ~nb_gen:!generations target_points in

    if !verbosity >= 1 then
    (
        Printf.printf "= End of evolution =\n";
        StatsPrinter.print_population pop;
        Printf.printf "= Final stats =\n";
        StatsPrinter.print_stats pop;
        StatsPrinter.print_advanced_stats pop
    )
    else
    (
        let bestFitness, bestDna = Stats.best_individual pop in
        Printf.printf "%f\n%s" bestFitness (FunctionDna.to_string bestDna)
    );

    if !show_graph then
    (
        Printf.printf "%!";

        try
            let graph = Plot.init ~size:(600,600) ~border:25 ~title:"GeneTipe" in
            Plot.plot ~color:Graphics.red ~link:false (Array.map fst target_points) (Array.map snd target_points) graph;
            Plot.plot_fun ~color:Graphics.blue (FunctionDna.eval (pop |> Stats.best_individual |> snd)) graph;
            Plot.show graph;
            while true do
                ignore (Graphics.wait_next_event [])
            done
        with Graphics.Graphic_failure _ -> ()
    )
;;
