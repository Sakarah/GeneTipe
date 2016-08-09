(** FunctionTree.t is the type of the genetic characteristics of a function
    internally represented by a tree. *)

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
