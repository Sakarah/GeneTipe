(** Parameters is the module where we define the parameters of the genetic algorithm.
    The module also provides a function to read them from a JSON file. *)

exception Error of string

(** Return a pattern list from the given json tree *)
val get_standard_pattern_list : string -> (string -> Yojson.Basic.json -> 'a) -> Yojson.Basic.json -> (float*'a) list

(** Read the parameters from the specified file.
    Optional pop_size and max_depth override the parameters in the file.
    This function must be called before any get_params execution *)
val read : ?pop_size:int -> ?max_depth:int -> filename:string -> unit

(** Return the parameters JSON tree *)
val get_json : unit -> Yojson.Basic.json

(** Return the evolution parameters *)
val get_evolution_params : unit -> (module EvolParams.S)