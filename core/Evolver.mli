(** Evolver contains all the functions related to creation and then evolution
    of a population. It implements natural selection mechanics and manage the
    population growth by mutation and crossover. *)

(** Initialize the population with randomly generated individuals using Koza's ramped half and half method *)
val init_population : unit -> (float option * Dna.t) array

(** Compute the fitness of all the individuals of a population *)
val compute_fitness : (float*float) array -> (float option * Dna.t) array -> (float * Dna.t) array

(** Simplify all the individuals from the given population (see Dna.simplify) *)
val simplify_individuals : ?generation:int -> (float * Dna.t) array -> (float * Dna.t) array

(** Organize a fight between functions to discard some of the weakest
    target_size is the size of the resulting population, it mustn't be greater than the input population size
    caution: target_size mustn't be less than half the input population size in this tournament *)
val tournament : (float * Dna.t) array -> target_size:int -> (float * Dna.t) array

(** Select the individuals to be copied for the next generation and crossovers by organizing fights between random packs of individuals
    target_size is the size of the resulting population, it mustn't be greater than the input population size *)
val tournament_by_packs : (float * Dna.t) array -> target_size:int -> (float * Dna.t) array

(** Recombine existing individuals and make mutations to create new functions *)
val reproduce : (float * Dna.t) array -> (float option * Dna.t) array

(** Evolve the population with the fixed number of generations *)
val evolve : (float*float) array -> (float * Dna.t) array -> (float * Dna.t) array
