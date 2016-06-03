(** Evolver contains all the functions related to creation and then evolution
    of a population. It implements natural selection mechanics and manage the
    population growth by mutation and crossover. *)

(** Initialize the population with randomly generated individuals *)
val init_population : size:int -> max_depth:int -> Dna.randomGenParams -> (float option * Dna.t) array

(** Measure how interesting a function is *)
val fitness : (float*float) array -> Dna.t -> float

(** Compute the fitness of all the individuals of a population *)
val compute_fitness : (float*float) array -> (float option * Dna.t) array -> (float * Dna.t) array

(** Organize a fight between functions to discard some of the weakest *)
val tournament : ('a * 'b) array -> target_size:int -> ('a * 'b) array

(** Recombine existing individuals and make mutations to create new functions *)
val reproduce : (float * Dna.t) array -> (float option * Dna.t) array

(** Evolve the population with the fixed number of generations *)
val evolve : (float option * Dna.t) array -> generations:int -> (float option * Dna.t) array
