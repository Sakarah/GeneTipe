(** Evolver contains all the functions related to creation and then evolution
    of a population. It implements natural selection mechanics and manage the
    population growth by mutation and crossover. *)

(** This type represents the parameters of a genetic selection process *)
type evolutionParams =
{
    max_depth : int ; (** Maximum depth in the Dna tree of an individual *)
    random_gen_params : Dna.randomGenParams ; (** Random generation parameters *)
    growth_factor : float ; (** Multiplication factor of the population after a reproduction phase *)
    mutation_ratio : float (** Ratio of the mutations in the reproduction phase. When not choosing mutation, a crossover is performed. *)
}

(** Initialize the population with randomly generated individuals using Koza's ramped half and half method *)
val init_population : size:int -> max_depth:int -> Dna.randomGenParams -> (float option * Dna.t) array

(** Measure how interesting a function is. The fitness is between 0 and 1, 1 indicating a good individual. *)
val fitness : (float*float) array -> Dna.t -> float

(** Compute the fitness of all the individuals of a population *)
val compute_fitness : (float*float) array -> (float option * Dna.t) array -> (float * Dna.t) array

(** Organize a fight between functions to discard some of the weakest 
    target_size is the size of the resulting population, it mustn't be greater than the input population size *)
val tournament : (float * Dna.t) array -> target_size:int -> (float * Dna.t) array

(** Recombine existing individuals and make mutations to create new functions *)
val reproduce : (float * Dna.t) array -> evolutionParams -> (float option * Dna.t) array

(** Evolve the population with the fixed number of generations *)
val evolve : (float*float) array -> evolutionParams -> (float * Dna.t) array -> (float * Dna.t) array
