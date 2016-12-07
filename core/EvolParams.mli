(** Module describing the parameter module type for an evolution process ({!S}) and its submodule types *)

(** Module type to carry the representation of an individual. *)
module type Individual =
sig
    type t (** Type of the genetically modifiable individual *)
    val to_string : t -> string (** Function for getting the string representation of an individual. *)
    val advanced_stats : (string * ((float*t) array -> float)) list (** List of the advanced stats functions for a population of individuals *)
    val plot : t -> Plot.graph -> unit (** Plot the individual on the given graph. *)
end

(** Module type to carry the representation of the target data *)
module type TargetData =
sig
    type t (** Type of the target data *)
    val read : unit -> t (** Read the target data from the given channel *)
    val plot : t -> Plot.graph -> unit (** Plot the target data on the given graph. *)
end

(** This module type represents the parameters of a genetic selection process *)
module type S =
sig
    module Individual : Individual (** Individual type used for the evolution *)
    module TargetData : TargetData (** Target data module *)

    val pop_size : int (** Number of individuals in the population *)
    val growth_factor : float (** Multiplication factor of the population after a reproduction phase *)
    val crossover_ratio : float (** Ratio of the crossovers in the reproduction phase. *)
    val mutation_ratio : float (** Ratio of the mutations in the reproduction phase. *)
    (** When not choosing mutation or crossover a new random individual is generated using a creation function. *)

    val creation : (float * (pop_frac:float -> Individual.t)) list (** List of the creation patterns with their probabilities *)
    val mutation : (float * (Individual.t -> Individual.t)) list (** List of mutations patterns with their associated probabilities *)
    val crossover : (float * (Individual.t -> Individual.t -> Individual.t)) list (** List of crossovers patterns with their associated probabilities *)
    val simplifications : (int * (Individual.t -> Individual.t)) list (** List of the simplifications patterns to apply to the population each n turn *)
    val fitness : TargetData.t -> Individual.t -> float (** Fitness function to use *)
    val selection : (float * Individual.t) array -> target_size:int -> (float * Individual.t) array (** Function for selecting the individuals to be copied for the next generation *)
    val parent_chooser : (float * Individual.t) array -> unit -> Individual.t (** Function used to randomly pick one individual for beeing a parent in the reproduction phase. *)
end
