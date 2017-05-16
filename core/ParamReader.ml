exception ParsingError of string;;
exception OverridingError of string;;

open Yojson.Basic.Util;;

let get_params global_json = function
    | `String name when name.[0] = '&' -> member name global_json
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

let load_plugins json =
    try
        let plugin_dir = json |> member "plugin_dir" |> to_string in
        let plugin_list = json |> member "plugins" |> to_list |> filter_string in
        List.iter (fun plugin -> Plugin.load (plugin_dir^plugin)) plugin_list
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (ParsingError ("plugins: "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

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
                    with Failure _ -> raise (OverridingError (key^" must be an integer for matching a list element")))
                | _ -> raise (OverridingError (key^" cannot be matched as there is a leaf in the original JSON tree"))
;;

let is_alpha = function
    | 'A'..'Z' | 'a'..'z' -> true
    | _ -> false
;;

let apply_overrides json =
    let apply_override json (key,j) =
        let new_json =
            if String.length j > 0 && (is_alpha j.[0]) then `String j
            else Yojson.Basic.from_string ~fname:"<command line overriding>" j
        in
        let path = Str.split (Str.regexp "/") key in
        override path new_json json
    in
    List.fold_left apply_override json
;;

module type JsonTree = sig val json : Yojson.Basic.json end;;
let read_json_tree ?(config_overrides=[]) ~filename =
    let json_tree = apply_overrides (Yojson.Basic.from_file filename) config_overrides in
    load_plugins json_tree;
    (module struct let json = json_tree end : JsonTree)
;;

module ReadConfig (GeneticHooks : Plugin.GeneticHooks) (ConfigJson : JsonTree) () =
struct
    module Individual = GeneticHooks.Individual;;
    type target_data = GeneticHooks.target_data;;
    module Fitness = (val get_method "fitness" GeneticHooks.Fitness.get ConfigJson.json);;

    let pop_size = ConfigJson.json |> member "pop_size" |> to_int;;
    let growth_factor = ConfigJson.json |> member "growth_factor" |> to_number;;
    let crossover_ratio = ConfigJson.json |> member "crossover_ratio" |> to_float;;
    let mutation_ratio = ConfigJson.json |> member "mutation_ratio" |> to_float;;
    let remove_duplicates = ConfigJson.json |> member "remove_duplicates" |> to_bool;;

    let creation = get_proba_pattern_list "creation" GeneticHooks.Creation.get ConfigJson.json;;
    let mutation = get_proba_pattern_list "mutation" GeneticHooks.Mutation.get ConfigJson.json;;
    let crossover = get_proba_pattern_list "crossover" GeneticHooks.Crossover.get ConfigJson.json;;
    let simplifications = get_scheduled_pattern_list "simplifications" GeneticHooks.Simplification.get ConfigJson.json;;

    let selection =
        let module SelectionMethod = (val get_method "selection" Plugin.Selection.get ConfigJson.json) in
        let module SelectionFunction = SelectionMethod (Fitness) in
        SelectionFunction.f
    ;;

    let parent_chooser =
        let module ParentChooserMethod = (val get_method "parent_choice" Plugin.ParentChooser.get ConfigJson.json) in
        let module ParentChooserFunction = ParentChooserMethod (Fitness) in
        ParentChooserFunction.f
    ;;
end;;
