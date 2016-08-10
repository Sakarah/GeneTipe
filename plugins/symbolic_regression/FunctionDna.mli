(** FunctionDna is the module describing the type of the individuals for the symbolic regression. *)

(** FunctionDna.t is the type of the genetic characteristics of a function internally represented by a tree. *)
type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X


(** {2 Evaluation and printing} *)
(** Evaluate the function represented by the DNA tree on the point x.
    By using curryfication, you can get the function without doing the evaluation.
    This function return nan if the function cannot be evaluated on the point x. *)
val eval : t -> float -> float

(** Retrurn the depth of the DNA tree *)
val depth : t -> int

(** Give a string representation of the DNA *)
val to_string : t -> string

(** Print the function *)
val print : Format.formatter -> t -> unit


(** {2 Advanced stats} *)
(** Return the average depth of the population *)
val average_depth : (float * t) array -> float

(** Return the diversity of depth in the population and return a percentage *)
val depth_diversity : (float * t) array -> float

(** Return a measurement of the genetic diversity of the population 
    computes the variance of number of each operator in the population and add them
    Return a percentage *)
val operator_diversity : (float * t) array -> float

(** List of the advanced stats functions for a function tree *)
val advanced_stats : (string * ((float*t) array -> float)) list