exception Error of string;;

open Yojson.Basic.Util;;

let get_params global_json = function
    | `String name -> member name global_json
    | json -> json
;;

let get_standard_pattern_list type_name method_getter json =
    try
        let get_pattern pattern_json =
            let proba = pattern_json |> member "proba" |> to_float in
            let method_name = pattern_json |> member "method" |> to_string in
            let params = pattern_json |> member "params" |> get_params json in
            (proba, method_getter method_name params)
        in
        json |> member type_name |> to_list |> List.map get_pattern
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error (type_name^": "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let get_creation_patterns = get_standard_pattern_list "creation" Plugin.Creation.get;;
let get_mutation_patterns = get_standard_pattern_list "mutation" Plugin.Mutation.get;;
let get_crossover_patterns = get_standard_pattern_list "crossover" Plugin.Crossover.get;;

let get_fitness_evaluator json =
    try
        let fitness_json = json |> member "fitness" in
        let fitness_method_name = fitness_json |> member "method" |> to_string in
        let params = fitness_json |> member "params" |> get_params json in
        Plugin.Fitness.get fitness_method_name params
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error ("fitness: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let get_simplification_patterns json =
    try
        let get_pattern pattern_json =
            let schedule = pattern_json |> member "schedule" |> to_int in
            let method_name = pattern_json |> member "method" |> to_string in
            let params = pattern_json |> member "params" |> get_params json in
            (schedule, Plugin.Simplification.get method_name params)
        in
        json |> member "simplifications" |> to_list |> List.map get_pattern
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error ("simplifications: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let to_evolution_params ?pop_size json =
    try
        let module FitnessEvaluator = (val get_fitness_evaluator json) in
        (module struct
            module Individual = Dna
            module TargetData = FitnessEvaluator.TargetData
        
            let pop_size =
            ( match pop_size with
                | None -> json |> member "pop_size" |> to_int
                | Some n -> n
            );;
            let growth_factor = json |> member "growth_factor" |> to_number;;
            let mutation_ratio = json |> member "mutation_ratio" |> to_float;;

            let creation = get_creation_patterns json;;
            let mutation = get_mutation_patterns json;;
            let crossover = get_crossover_patterns json;;
            let fitness = FitnessEvaluator.fitness;;
            let simplifications = get_simplification_patterns json;;
        end : EvolParams.S)
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error ("evolution: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let load_plugins json =
    try
        let plugin_dir = json |> member "plugin_dir" |> to_string in
        let plugin_list = json |> member "plugins" |> to_list |> filter_string in
        List.iter (fun plugin -> Plugin.load (plugin_dir^plugin)) plugin_list
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error ("plugins: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let json_tree = ref None;;
let evol_params = ref None;;

let read ?pop_size ~filename =
    try
        let json = Yojson.Basic.from_file filename in
        json_tree := Some json;
        load_plugins json;
        evol_params := Some (to_evolution_params ?pop_size json)
    with Error str ->
        raise (Error ("Unable to load configuration from "^filename^": "^str))
;;

let get_ref v = match !v with
    | Some var -> var
    | None -> raise (Error "Not loaded configuration file")
;;

let get_json () = get_ref json_tree;;
let get_evolution_params () = get_ref evol_params;;
