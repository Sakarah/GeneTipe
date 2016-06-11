(** Dna.t is the type of the genetic characteristics of an individual function
    internally represented by a tree. It allows diferent kind of genetic manipulation
    like random generation, crossover or evaluation of the underlying function.
    All functions directly manipulating DNA should be found in this module. *)

type t =
    | BinOp of string*(float->float->float)*t*t
    | UnOp of string*(float->float)*t
    | Const of float
    | X

(** {2 Random generation} *)
(** Randomly generate a new individual who has a depth below max_depth *)
val create_random_grow : max_depth:int -> Parameters.randomGen -> t

(** Randomly generate a new individual who has a depth of exactly max_depth (for all branches) *)
val create_random_fill : max_depth:int -> Parameters.randomGen -> t

(** Randomly generate a new individual choosing between the grow or the fill method *)
val create_random : max_depth:int -> Parameters.randomGen -> t


(** {2 Gene manipulation} *)
(** Generate a new individual by doing a crossover wich replace some parts of the first dna by elements of the second.
    The replacement takes place at the exact depth specified or before if we encounter a terminal node *)
val crossover : crossover_depth:int -> t -> t -> t

(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics.
    The replacement takes place at the exact depth specified or before if we encounter a terminal node.
    The new genes added are taken in order to ensure that max_depth is never exceeded. *)
val mutation : mutation_depth:int -> max_depth:int -> Parameters.randomGen -> t -> t

(** Generate a new individual by tweaking constants of an already existing one *)
val mutate_constants : range:(float*float) -> proba:float -> t -> t


(** {2 Evaluation and printing} *)
(** Evaluate the function represented at the point x.
    If any exceptions is caught during the mathematical evaluation, the exception IllFormed will be raised.
    It will have to be caught during the Evolver.tournament function. *)
val eval : float -> t -> float

(** Simplifies a function evaluating all constants. 
    e.g. cos(3.14) -> 1.00 *)
val simplify : t -> t 

(** Give a string representation of the DNA *)
val to_string : ?bracket:bool -> t -> string

(** Print the DNA *)
val print : Format.formatter -> t -> unit
