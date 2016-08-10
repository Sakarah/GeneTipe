(** This module is intended to compute and print some basic statistics about a population. *)

(** Return the best individual from the population *)
val best_individual : (float * 'i) array -> (float * 'i)

(** Retrurn the average value of the evaluation of the given function on the population *)
val average : ('i -> float) -> 'i array -> float

(** Return the average fitness of the population *)
val average_fitness : (float * 'i) array -> float

(** Return the statistical variance of the evaluation of the given function on the population *)
val variance : ('i -> float) -> 'i array -> float

(** Retrurn the diversity of the evaluation of the given function on the population.
    The diversity is a value between 0 and 1, 0 meaning identical results, 1 meaning radically different ones. *)
val diversity : ('i -> float) -> 'i array -> float

(** Output type of {!MakePrinter} *)
module type Printer =
sig
    type individual
    
    (** Print generic statistics about the given population *)
    val print_stats : (float * individual) array -> unit

    (** Print more statistics about the given population. The statistics shown depend on the individual type. *)
    val print_advanced_stats : (float * individual) array -> unit
    
    (** Print the entire population *)
    val print_population : (float * individual) array -> unit
end

(** Create a new Printer around the given Individual type. *)
module MakePrinter : functor (Individual : EvolParams.Individual) -> Printer with type individual := Individual.t
