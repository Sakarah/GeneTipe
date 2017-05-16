(** Module describing the parameter module type for an evolution process ({!S}) and its submodule types *)

(** Module type to carry the representation of an individual. *)
module type Individual =
sig
    type t (** Type of the genetically modifiable individual *)
    val to_string : t -> string (** Function for getting the string representation of an individual. *)
    val advanced_stats : (string * (t array -> float)) list (** List of the advanced stats functions for a population of individuals *)
end

(** Module to carry fitness value for an individual and compare two fitness values. A fitness value should tell how well the given individual matches the target data. *)
module type Fitness =
sig
    type t
    type individual
    type target_data

    val to_string : t -> string (** Get the string representation of a fitness value *)
    val to_float : t -> float (** Give a float positive value associated with the fitness. Greater values mean better fitness (and individuals). Raise Invalid_argument if impossible to compute. *)
    val compare : t -> t -> int (** Compare 2 fitness values (using the convention of {!Pervasives.compare}) *)
    val compute : target_data -> individual -> t (** Compute the fitness for an individual according to the target data given. *)
end

(** This module type represents the parameters of a genetic selection process *)
module type S =
sig
    module Individual : Individual (** Individual type used for the evolution *)
    type target_data (** Target data type *)
    module Fitness : Fitness with type individual = Individual.t and type target_data = target_data (** Fitness data type module *)

    val pop_size : int (** Number of individuals in the population *)
    val growth_factor : float (** Multiplication factor of the population after a reproduction phase *)
    val crossover_ratio : float (** Ratio of the crossovers in the reproduction phase. *)
    val mutation_ratio : float (** Ratio of the mutations in the reproduction phase. *)
    (** When not choosing mutation or crossover a new random individual is generated using a creation function. *)
    val remove_duplicates : bool (** If this is set to true, replace duplicates by new randomly generated individuals after each reproduction. *)

    val creation : (float * (target_data -> pop_frac:float -> Individual.t)) list (** List of the creation patterns with their probabilities *)
    val mutation : (float * (target_data -> Individual.t -> Individual.t)) list (** List of mutations patterns with their associated probabilities *)
    val crossover : (float * (Individual.t -> Individual.t -> Individual.t)) list (** List of crossovers patterns with their associated probabilities *)
    val simplifications : (int * (Individual.t -> Individual.t)) list (** List of the simplifications patterns to apply to the population each n turn *)
    val selection : (Fitness.t * Individual.t) array -> target_size:int -> (Fitness.t * Individual.t) array (** Function for selecting the individuals to be copied for the next generation *)
    val parent_chooser : (Fitness.t * Individual.t) array -> unit -> Individual.t (** Function used to randomly pick one individual for beeing a parent in the reproduction phase. *)
end
