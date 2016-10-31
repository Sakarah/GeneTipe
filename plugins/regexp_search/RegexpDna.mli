(** RegexpDna is a module intended to provides an overlay of {!RegexpTree} to satisfy the {!EvolParams.Individual} requirements.
    With this module we can use the regular expression trees as individuals in a genetic evolution process.
    All interesting functions about regexp tree are located in the {!RegexpTree} module except the advanced statistics about tree populations that are in this module. *)

(** RegexpDna.t is the type of the genetic characteristics of a regular expression internally represented by a {!RegexpTree}. *)
type t = RegexpTree.t

(** Direct call to {!RegexpTree.to_string} to satisfy {!EvolParams.Individual} requirements. *)
val to_string : t -> string

(** As plotting is meaningless for a regular expression this function does nothing. It is here only to satisfy {!EvolParams.Individual} requirements. *)
val plot : t -> Plot.graph -> unit


(** {2 Advanced stats} *)
(** Return the average depth of a population of regexp *)
val average_depth : (float * t) array -> float

(** Return the diversity of depth in the population and return a percentage *)
val depth_diversity : (float * t) array -> float

(** List of the advanced stats functions for a regexp population *)
val advanced_stats : (string * ((float*t) array -> float)) list
