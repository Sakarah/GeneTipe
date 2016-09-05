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

(** Read the parameters from the specified file.
    This function must be called before any get_* execution.
    @param config_overrides Optional (key,value) list to override the parameters in the file.
    The key correspond to the location of the replacement in as a ["/"] separated path using numbers for browsing into lists.
    The value is evaluated as a JSON subtree or if it starts with an alpha character is interpreted as a string *)
val read : ?config_overrides:(string*string) list -> filename:string -> unit

(** Return the parameters JSON tree *)
val get_json : unit -> Yojson.Basic.json

(** Return the evolution parameters *)
val get_evolution_params : unit -> (module EvolParams.S)
