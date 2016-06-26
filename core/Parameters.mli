(** Parameters is the module where we define the parameters of the genetic algorithm.
    The module also provides a function to read them from a JSON file. *)

exception Error of string

(** This type represents the parameters of a genetic selection process *)
type t =
{
    pop_size : int ; (** Number of individuals in the population *)
    max_depth : int ; (** Maximum depth in the Dna tree of an individual *)
    growth_factor : float ; (** Multiplication factor of the population after a reproduction phase *)
    mutation_ratio : float ; (** Ratio of the mutations in the reproduction phase. When not choosing mutation, a crossover is performed. *)

    creation : (float * (max_depth:int -> Dna.t)) list ; (** List of the creation patterns with their probabilities *)
    mutation : (float * (max_depth:int -> Dna.t -> Dna.t)) list ; (** List of mutations patterns with their associated probabilities *)
    crossover : (float * (Dna.t -> Dna.t -> Dna.t)) list ; (** List of crossovers patterns with their associated probabilities *)
    fitness : (float*float) array -> Dna.t -> float ; (** Fitness function to use *)
    simplifications : (int * (Dna.t -> Dna.t)) list (** List of the simplifications patterns to apply to the population each n turn *)
}

(** Read the parameters from the specified file.
    Optional pop_size and max_depth override the parameters in the file.
    This function must be called before any get_params execution *)
val read : ?pop_size:int -> ?max_depth:int -> filename:string -> unit

(** Return the parameters *)
val get : unit -> t
