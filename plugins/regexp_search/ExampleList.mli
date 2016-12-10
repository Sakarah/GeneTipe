(** This module defines the type of the target data for a regular expression search from examples.*)

(** The first list defines positive examples. The second contains the counter-examples *)
type t = string array * string array

(** Read the examples from standard input channel. Read the number of positive examples first, then all the positive examples
    and do the same for the negative examples.*)
val read : unit -> t

(** This function does noting and is here for satisfy the {!EvolParams.TargetData} interface *)
val plot : t -> Plot.graph -> unit
