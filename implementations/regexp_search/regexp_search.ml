let () =
    (* Command line parsing *)
    let generations = ref 100 in
    let config_overrides = ref [] in
    let next_overriden_key = ref "" in
    let verbosity = ref 2 in
    let dump_filename = ref "" in
    let load_filename = ref "" in
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
             " Override a configuration value (for accessing a subkey use / separator) by a new given JSON tree. \
             (Takes 2 parameters : the key and the new JSON value)");
        ("-c", Arg.Tuple [Arg.Set_string next_overriden_key; Arg.String (function json -> config_overrides := (!next_overriden_key,json)::(!config_overrides))],
            " Shorthand for --config-override");
        ("--quiet", Arg.Unit (fun () -> verbosity := 0), " Do not print anything else than the best individual at the end of the evolution process (equivalent to -v 0)");
        ("--no-stats", Arg.Unit (fun () -> verbosity := 1), " Only print the best individual each generation (equivalent to -v 1)");
        ("--full-stats", Arg.Unit (fun () -> verbosity := 3), " Print full intermediate statistics about the currently generated population (equivalent to -v 3)");
        ("-v", Arg.Set_int verbosity, "verbLevel Set the verbosity level (default is 2). Lower values speed up the process");
        ("--dump-pop", Arg.Set_string dump_filename, "filename Dump the final population into the given file (creating or replacing it) for future reuse with the --load-pop command");
        ("-d", Arg.Set_string dump_filename, "filename Shorthand for --dump-pop");
        ("--load-pop", Arg.Set_string load_filename, "filename Load the dumped population in the given file as the initial population of the genetic evolution");
        ("-l", Arg.Set_string load_filename, "filename Shorthand for --load-pop");
    ]
    in

    let usage_msg =
        "Regular expression searching tool of the GeneTipe project.\n\
        This program waits as input a list of examples and counter-examples of strings that should be used to infer a regular expression.\n\
        Each line is treated as a single example if it starts with a '+' and as a counter-example if it starts with a '-'. Without any '+' or '-', a line is ignored. The example must immediately follow the sign without space.\n\
        It creates and evolve a population of candidate regular expressions with a genetic algorithm.\n\
        All the genetic operators on the population must be provided through plugins loaded dynamically.\n\
        You need to provide a configuration file specifying the required plugins and the parameters of the evolution process.\n\
        Usage: regexp-search [options] configFilename\n\
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

    (* Load the initial population if a file is given *)
    let init_pop = match !load_filename with
        | "" -> None
        | file ->
            let pop_file = open_in_bin file in
            Some (Marshal.from_channel pop_file)
    in

    (* Read the target data and evolve the population *)
    let target_data = ExampleList.read () in
    let pop = RegexpEvolver.evolve ?init_pop ~verbosity:!verbosity ~nb_gen:!generations target_data in

    (* Print final statistics about the last generation (or just the best individual if the verbosity is null) *)
    if !verbosity >= 2 then
    (
        Printf.printf "= End of evolution =\n";
        StatsPrinter.print_population pop;
        Printf.printf "= Final stats =\n";
        StatsPrinter.print_stats pop;
        StatsPrinter.print_advanced_stats pop;
        let (ex, cex) = target_data in
        Printf.printf "(Extracted from %d examples and %d counter-examples)\n" (Array.length ex) (Array.length cex)
    )
    else if !verbosity = 0 then
    (
        let bestFitness, bestDna = Stats.best_individual Parameters.Fitness.compare pop in
        Printf.printf "%s\n%s" (Parameters.Fitness.to_string bestFitness) (RegexpDna.to_string bestDna)
    );

    (* Dump the final population if required *)
    if !dump_filename <> "" then
    (
        let out_file = open_out_bin !dump_filename in
        Marshal.to_channel out_file pop []
    )
;;
