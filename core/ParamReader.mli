(** Parameters is the module where we define the parameters of the genetic algorithm.
    The module also provides a function to read them from a JSON file. *)

exception ParsingError of string
exception OverridingError of string

(** Return a pattern list from the given json tree *)
val get_standard_pattern_list : string -> (string -> Yojson.Basic.json -> 'a) -> Yojson.Basic.json -> (float*'a) list

(** Read the parameters from the specified file.
    Optional config_overrides is a (key,value) list to override the parameters in the file.
    The key correspond to the location of the replacement in a / separated form using numbers for browsing into lists.
    This function must be called before any get_params execution *)
val read : ?config_overrides:(string*string) list -> filename:string -> unit

(** Return the parameters JSON tree *)
val get_json : unit -> Yojson.Basic.json

(** Return the evolution parameters *)
val get_evolution_params : unit -> (module EvolParams.S)