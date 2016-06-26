(** Dna.t is the type of the genetic characteristics of an individual function
    internally represented by a tree. It allows diferent kind of genetic manipulation
    like random generation, crossover or evaluation of the underlying function. *)

type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X

(** {2 Random generation} *)
(** Randomly generate a new individual using the provided patterns *)
val create_random : (float * (max_depth:int -> t)) list -> max_depth:int -> t


(** {2 Gene manipulation} *)
(** Generate a new individual by modifying an existing individual adding him new characteristics using provided patterns *)
val mutation : (float * (max_depth:int -> t -> t)) list -> max_depth:int -> t -> t

(** Generate a new individual by taking characteristics of another individual using the provided patterns *)
val crossover : (float * (t -> t -> t)) list -> t -> t -> t


(** {2 Evaluation and printing} *)
(** Evaluate the function represented by the DNA on the point x.
    By using curryfication, you can get the function without doing the evaluation.
    This function return nan if the function cannot be evaluated on the point x. *)
val eval : t -> float -> float

(** Retrurn the depth of the DNA tree *)
val depth : t -> int

(** Give a string representation of the DNA *)
val to_string : ?bracket:bool -> t -> string

(** Print the DNA *)
val print : Format.formatter -> t -> unit
