exception ParsingError of string;;
exception OverridingError of string;;

open Yojson.Basic.Util;;

let get_params global_json = function
    | `String name -> member name global_json
    | json -> json
;;

let get_method type_name method_getter json =
    try
        let method_json = json |> member type_name in
        let method_name = method_json |> member "method" |> to_string in
        let params = method_json |> member "params" |> get_params json in
        method_getter method_name params
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError (type_name^": "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let get_proba_pattern_list type_name method_getter json =
    try
        let get_pattern pattern_json =
            let proba = pattern_json |> member "proba" |> to_float in
            let method_name = pattern_json |> member "method" |> to_string in
            let params = pattern_json |> member "params" |> get_params json in
            (proba, method_getter method_name params)
        in
        json |> member type_name |> to_list |> List.map get_pattern
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError (type_name^": "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let get_scheduled_pattern_list type_name method_getter json =
    try
        let get_pattern pattern_json =
            let schedule = pattern_json |> member "schedule" |> to_int in
            let method_name = pattern_json |> member "method" |> to_string in
            let params = pattern_json |> member "params" |> get_params json in
            (schedule, method_getter method_name params)
        in
        json |> member type_name |> to_list |> List.map get_pattern
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError (type_name^": "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let to_evolution_params json =
    try
        let module GeneticType = (val Plugin.GeneticType.get (json |> member "type" |> to_string)) in
        let module FitnessEvaluator = (val get_method "fitness" GeneticType.Fitness.get json) in
        (module struct
            module Individual = GeneticType.Individual
            module TargetData = FitnessEvaluator.TargetData
        
            let pop_size = json |> member "pop_size" |> to_int;;
            let growth_factor = json |> member "growth_factor" |> to_number;;
            let mutation_ratio = json |> member "mutation_ratio" |> to_float;;

            let creation = get_proba_pattern_list "creation" GeneticType.Creation.get json;;
            let mutation = get_proba_pattern_list "mutation" GeneticType.Mutation.get json;;
            let crossover = get_proba_pattern_list "crossover" GeneticType.Crossover.get json;;
            let fitness = FitnessEvaluator.fitness;;
            let simplifications = get_scheduled_pattern_list "simplifications" GeneticType.Simplification.get json;;
        end : EvolParams.S)
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError ("evolution: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let load_plugins json =
    try
        let plugin_dir = json |> member "plugin_dir" |> to_string in
        let plugin_list = json |> member "plugins" |> to_list |> filter_string in
        List.iter (fun plugin -> Plugin.load (plugin_dir^plugin)) plugin_list
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError ("plugins: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

let json_tree = ref None;;
let evol_params = ref None;;

let get_ref v = match !v with
    | Some var -> var
    | None -> failwith "Not loaded configuration file"
;;
let get_json () = get_ref json_tree;;
let get_evolution_params () = get_ref evol_params;;

let rec override replacement_path new_json base_json =
    match replacement_path with
        | [] -> new_json
        | key::path_tail ->
            let rec process_assoc_list = function
                | [] -> raise (OverridingError (key^" not found in the original JSON tree"))
                | (k,child_json)::t when k = key -> (k, override path_tail new_json child_json)::t
                | v::t -> v::(process_assoc_list t)
            in
            
            let rec process_ord_list index = function
                | [] -> raise (OverridingError ("Index outside bounds"))
                | child_json::t when index = 0 -> (override path_tail new_json child_json)::t
                | child_json::t -> child_json::(process_ord_list (index-1) t)
            in
            
            match base_json with
                | `Assoc assoc_list -> `Assoc (process_assoc_list assoc_list)
                | `List ord_list -> 
                    (try 
                        let index = int_of_string key in
                        `List (process_ord_list index ord_list)
                    with Failure "int_of_string" -> raise (OverridingError (key^" must be an integer for matching a list element")))
                | _ -> raise (OverridingError (key^" cannot be matched as there is a leaf in the original JSON tree"))
;;

let is_alpha = function 
    | 'A'..'Z' | 'a'..'z' -> true 
    | _ -> false
;;

let apply_overrides =
    let apply_override (key,j) =
        let new_json = 
            if String.length j > 0 && (is_alpha j.[0]) then Yojson.Basic.from_string ~fname:"<command line overriding>" ("\""^j^"\"")
            else Yojson.Basic.from_string ~fname:"<command line overriding>" j 
        in
        let path = Str.split (Str.regexp "/") key in
        json_tree := Some (override path new_json (get_json ()))
    in
    List.iter apply_override
;;

let read ?(config_overrides=[]) ~filename =
    json_tree := Some (Yojson.Basic.from_file filename);
    apply_overrides config_overrides;
    load_plugins (get_json ());
    evol_params := Some (to_evolution_params (get_json ()))
;;
