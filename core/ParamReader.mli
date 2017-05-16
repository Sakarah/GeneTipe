(** Module for reading the evolution parameters from a JSON file. *)

(** Exception raised if there is a parsing error of the file *)
exception ParsingError of string

(** Exception raised in case of configuration overriding failure. *)
exception OverridingError of string


(** Return a single method from the given JSON tree *)
val get_method : string -> (string -> Yojson.Basic.json -> 'a) -> Yojson.Basic.json -> 'a

(** Return a probabilized pattern list from the given JSON tree *)
val get_proba_pattern_list : string -> (string -> Yojson.Basic.json -> 'a) -> Yojson.Basic.json -> (float*'a) list

(** Return a scheduled pattern list from the given JSON tree*)
val get_scheduled_pattern_list : string -> (string -> Yojson.Basic.json -> 'a) -> Yojson.Basic.json -> (int*'a) list


(** Basic module with a single JSON tree inside. *)
module type JsonTree = sig val json : Yojson.Basic.json end

(** Read the JSON tree from the file specified in ConfigFileInfo.
    @param config_overrides Optional (key,value) list to override the parameters in the file.
    The key correspond to the location of the replacement in as a ["/"] separated path using numbers for browsing into lists.
    The value is evaluated as a JSON subtree or if it starts with an alpha character is interpreted as a string *)
val read_json_tree : ?config_overrides:(string*string) list -> filename:string -> (module JsonTree)

(** Read the parameters from the specified JSON tree.
    GeneticHooks are used to match the genetic operator names with their associated function. *)
module ReadConfig (GeneticHooks : Plugin.GeneticHooks) (ConfigJson : JsonTree) () : EvolParams.S with module Individual = GeneticHooks.Individual and type target_data = GeneticHooks.target_data
