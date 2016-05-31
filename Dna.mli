(** Dna.t is the type of the genetic characteristics of an individual function
    internally represented by a tree. It allows diferent kind of genetic manipulation
    like random generation, crossover or evaluation of the underlying function.
    All functions directly manipulating DNA should be found in this module. **)

type t
exception IllFormed

(** This type represents the parameters for random generation of an individual **)
type randomGenParams =
{
    fill_proba: float;
    bin_op:(float * string * (float -> float -> float)) array ;
    bin_proba:float ;
    un_op:(float * string * (float -> float)) array ;
    un_proba:float ;
    const_range:(float*float) ;
    const_proba:float
    (* The rest of the probabilities represent the choice of the variable (x) *)
}

(** Randomly generate a new individual who has a depth below max_depth **)
val create_random_grow : max_depth:int -> randomGenParams -> t
(** Randomly generate a new individual who has a depth of exactly max_depth **)
val create_random_fill : max_depth:int -> randomGenParams -> t
(** Randomly generate a new individual choosing between the grow or the fill method **)
val create_random : max_depth:int -> randomGenParams -> t

(** Generate a new individual by doing a crossover wich replace some parts of the first dna by elements of the second **)
val crossover : depth:int -> t -> t -> t
(** Generate a new individual by modifying an existing individual adding him new randomly generated characteristics **)
val mutation : depth:int -> randomGenParams -> t -> t
(** Generate a new individual by tweaking constants of an already existing one **)
val mutate_constants : range:(float*float) -> proba:float -> t -> t

(** Evaluate the function represented at the point x.
    If any exceptions is caught during the mathematical evaluation, the exception IllFormed will be raised.
    It will have to be caught during the Evolver.tournament function. **)
val eval : float -> t -> float

(** Give a string representation of the DNA **)
val to_string : ?bracket:bool -> t -> string
(** Print the DNA **)
val print : Format.formatter -> t -> unit
