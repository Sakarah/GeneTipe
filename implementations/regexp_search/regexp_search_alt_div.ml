let () =
    (* Command line parsing *)
    let generations = ref 100 in
    let config_overrides = ref [] in
    let next_overriden_key = ref "" in
    let verbosity = ref 2 in
    let alt_rounds = ref 5 in
    let config_filename = ref "" in

    let spec_list =
    [
        ("--gen", Arg.Set_int generations, "nbGen Set the number of generations (default is 100)");
        ("-g", Arg.Set_int generations, "nbGen Shorthand for --gen");
        ("--rand", Arg.Int (function r -> Random.init r), "seed Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "seed Shorthand for --rand");
        ("--pop", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "popSize Set the population size (override the config file)");
        ("-p", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "popSize Shorthand for --pop");
        ("--alt-round", Arg.Set_int alt_rounds, "n Set the number of alternative rounds (default is 5)");
        ("-a", Arg.Set_int alt_rounds, "n Shorthand for --alt-round");
        ("--config-override", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
             " Override a configuration value (for accessing a subkey use / separator) by a new given JSON tree. \
             (Takes 2 parameters : the key and the new JSON value)");
        ("-c", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            " Shorthand for --config-override");
        ("--quiet", Arg.Unit (fun () -> verbosity := 0), " Do not print anything else than the best individual at the end of the evolution process (equivalent to -v 0)");
        ("--no-stats", Arg.Unit (fun () -> verbosity := 1), " No intermediate statistics about the currently generated population (equivalent to -v 1)");
        ("--full-stats", Arg.Unit (fun () -> verbosity := 3), " Print full intermediate statistics about the currently generated population (equivalent to -v 3)");
        ("-v", Arg.Set_int verbosity, "verbLevel Set the verbosity level (default is 2). Lower values speed up the process");
    ]
    in

    let usage_msg =
        "Regular expression searching tool of the GeneTipe project using a divide and conquer strategy to manage alternatives (| in regexp).\n\
        This program waits as input a list of examples and counter-examples of strings that should be used to infer a regular expression.\n\
        Each line is treated as a single example if it starts with a '+' and as a counter-example if it starts with a '-'. Without any '+' or '-', a line is ignored. The example must immediately follow the sign without space.\n\
        It creates and evolve a population of candidate regular expressions with a genetic algorithm.\n\
        All the genetic operators on the population must be provided through plugins loaded dynamically.\n\
        You need to provide a configuration file specifying the required plugins and the parameters of the evolution process.\n\
        Usage: regexp-search-alt-d&c [options] configFilename\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun cfg_file -> config_filename := cfg_file) usage_msg;
    if !config_filename = "" then raise (Arg.Bad "No config file given");

    (* Load the configuration file and create the evolver module from the parameters *)
    let module ParamJson = (val ParamReader.read_json_tree ~config_overrides:!config_overrides ~filename:!config_filename) in
    let module Parameters = ParamReader.ReadConfig (RegexpSearchHooks) (ParamJson) () in
    let module RegexpEvolver = Evolver.Make (Parameters) in
    let module StatsPrinter = Stats.MakePrinter (RegexpDna) (Parameters.Fitness) in

    let target_data = ExampleList.read () in

    let rec perform_alt_rounds ?prefix round_number =
        let filtered_data = match prefix with
            | None -> target_data
            | Some re -> ExampleList.remove_matching target_data re
        in
        if Array.length (fst filtered_data) = 0 then
        (
            match prefix with
                | None -> failwith "Empty example set"
                | Some p -> p
        )
        else
        (
            let pop = RegexpEvolver.evolve ~verbosity:!verbosity ~nb_gen:!generations filtered_data in

            if !verbosity >= 1 then
            (
                Printf.printf "== End of round #%d ==\n" round_number;
                StatsPrinter.print_population pop;
                Printf.printf "= Round stats =\n";
                StatsPrinter.print_stats pop;
                StatsPrinter.print_advanced_stats pop;
                let (ex, cex) = filtered_data in
                Printf.printf "(Extracted from %d examples and %d counter-examples)\n" (Array.length ex) (Array.length cex)
            );

            let _, best_individual = Stats.best_individual Parameters.Fitness.compare pop in
            let next_prefix = match prefix with
                | None -> best_individual
                | Some pre -> RegexpTree.Alternative (pre,best_individual)
            in

            if !verbosity >= 1 then
            (
                let prefix_fitness = Parameters.Fitness.compute target_data next_prefix in
                Printf.printf "Current global regexp :\n";
                Printf.printf "%s ~ %s\n" (Parameters.Fitness.to_string prefix_fitness) (Parameters.Individual.to_string next_prefix)
            );

            if round_number = !alt_rounds then next_prefix
            else perform_alt_rounds ~prefix:next_prefix (round_number+1)
        )
    in
    let final_regexp = perform_alt_rounds 1 in
    let final_fitness = Parameters.Fitness.compute target_data final_regexp in

    if !verbosity >= 1 then Printf.printf "= End of evolution =\n";

    Printf.printf "%s\n%s\n" (Parameters.Fitness.to_string final_fitness) (RegexpDna.to_string final_regexp)
;;
