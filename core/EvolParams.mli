module type Individual =
sig
    type t (** Type of the genetically modifiable individuals *)
    val to_string : t -> string (** Function for getting the string representation of an individual. *)
end

(** This module type represents the parameters of a genetic selection process *)
module type S = 
sig
    module Individual : Individual
    
    val pop_size : int (** Number of individuals in the population *)
    val max_depth : int (** Maximum depth in the Dna tree of an individual *)
    val growth_factor : float (** Multiplication factor of the population after a reproduction phase *)
    val mutation_ratio : float (** Ratio of the mutations in the reproduction phase. When not choosing mutation, a crossover is performed. *)

    val creation : (float * (max_depth:int -> Individual.t)) list (** List of the creation patterns with their probabilities *)
    val mutation : (float * (max_depth:int -> Individual.t -> Individual.t)) list (** List of mutations patterns with their associated probabilities *)
    val crossover : (float * (Individual.t -> Individual.t -> Individual.t)) list (** List of crossovers patterns with their associated probabilities *)
    val simplifications : (int * (Individual.t -> Individual.t)) list (** List of the simplifications patterns to apply to the population each n turn *)
    val fitness : (float*float) array -> Individual.t -> float (** Fitness function to use *)
end