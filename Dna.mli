(** Dna.t is the type of the genetic characteristics of an individual function
    internally represented by a tree. It allows diferent kind of genetic manipulation
    like random generation, crossover or evaluation of the underlying function.
    All functions directly manipulating DNA should be found in this module. **)

type t
exception IllFormed

(** Randomly generate a new individual who has a depth below max_depth **)
val create_random : max_depth:int -> t

(** Generate a new individual by doing a crossover wich replace some parts of the first dna by elements of the second **)
val crossover : law:(int -> float) -> max_depth:int -> t -> t -> t
(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics **)
val mutation : law:(int -> float) -> max_depth:int -> t -> t

(** Evaluate the function represented at the point x **)
val eval : float -> t -> float

(** Give a string representation of the DNA **)
val to_string : ?bracket:bool -> t -> string
(** Print the DNA **)
val print : Format.formatter -> t -> unit
