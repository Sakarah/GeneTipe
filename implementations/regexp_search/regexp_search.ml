let () =
    let generations = ref 100 in
    let config_overrides = ref [] in
    let next_overriden_key = ref "" in
    let verbosity = ref 2 in
    let config_filename = ref "" in

    let spec_list =
    [
        ("--gen", Arg.Set_int generations, "Set the number of generations (default is 100)");
        ("-g", Arg.Set_int generations, "Shorthand for --gen");
        ("--rand", Arg.Int (function r -> Random.init r), "Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "Shorthand for --rand");
        ("--pop", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "Set the population size (override the config file)");
        ("-p", Arg.String (function p -> config_overrides := ("pop_size",p)::(!config_overrides)), "Shorthand for --pop");
        ("--config-override", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            "Override a configuration value (for accessing a subkey use / separator) by a new given json tree. (Takes 2 parameters)");
        ("-c", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            "Shorthand for --config-override");
        ("--quiet", Arg.Unit (fun () -> verbosity := 0), "Do not print anything else than the best individual at the end of the evolution process (equivalent to -v 0)");
        ("--no-stats", Arg.Unit (fun () -> verbosity := 1), "No intermediate statistics about the currently generated population (equivalent to -v 1)");
        ("--full-stats", Arg.Unit (fun () -> verbosity := 3), "Print full intermediate statistics about the currently generated population (equivalent to -v 3)");
        ("-v", Arg.Set_int verbosity, "Set the verbosity level (default is 2). Lower values speed up the process");
    ]
    in

    let usage_msg =
        "Regular expression searching tool of the GeneTipe project.\n\
        This program waits as input a list of examples followed by a list of counter examples of strings that should be used to infer a regular expression.\n\
        It creates and evolve a population of candidate regular expressions with an genetic algorithm.\n\
        All the genetic operators on the population must be provided through plugins loaded dynamically.\n\
        You need to provide it a configuration file specifying the required plugins and the parameters of the evolution process.\n\
        Usage: regexp-search [options] configFilename\n\
        \n\
        Options available:"
    in

    Arg.parse spec_list (fun cfg_file -> config_filename := cfg_file) usage_msg;
    if !config_filename = "" then raise (Arg.Bad "No config file given");

    let module ParamJson = (val ParamReader.read_json_tree ~config_overrides:!config_overrides ~filename:!config_filename) in
    let module Parameters = ParamReader.ReadConfig (RegexpSearchHooks) (ParamJson) in
    let module RegexpEvolver = Evolver.Make (Parameters) in
    let module StatsPrinter = Stats.MakePrinter (RegexpDna) in

    let target_data = ExampleList.read () in
    let pop = RegexpEvolver.evolve ~verbosity:!verbosity ~nb_gen:!generations target_data in

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
        Printf.printf "%f\n%s" bestFitness (RegexpDna.to_string bestDna)
    );
;;
