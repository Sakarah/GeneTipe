(** This modules give some statistics about a population *)

(** Return the best individual from the population *)
val best_individual : (float * 'i) array -> (float * 'i)

(** Retrurn the average value of the evaluation of the given function on the population *)
val pop_average : (float * 'i -> float) -> (float * 'i) array -> float

(** Return the average fitness of the population *)
val average_fitness : (float * 'i) array -> float

module type StringConvertible =
sig
    type t
    val to_string : t -> string
end

module type Printer =
sig
    type individual
    
    (** Print statistics about the given population *)
    val print_stats : (float * individual) array -> unit

    (** Print the entire population *)
    val print_population : (float * individual) array -> unit
end

module MakePrinter : functor (Individual : StringConvertible) -> Printer with type individual := Individual.t

(* == TREE ONLY == 
(** Return the average depth of the population *)
val average_depth : (float * Dna.t) array -> float

(** Return a measurement of the genetic diversity of the population 
    computes the variance of number of each operator in the population and add them
    Return a percentage *)
val operator_diversity : (float * Dna.t) array -> float

(** Return the diversity of depth in the population and return a percentage *)
val depth_diversity : (float * Dna.t) array -> float

(** Print more statistics about the given population *)
val print_advanced_stats : (float * Dna.t) array -> unit
== END OF TREE ONLY == *)