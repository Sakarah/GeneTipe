(** This modules give some statistics about a population *)

(** Return the best individual from the population *)
val best_individual : (float * Dna.t) array -> (float * Dna.t)

(** Return the average fitness of the population *)
val average_fitness : (float * Dna.t) array -> float

(** Return a measurment of the genetic diversity of the population *)
val genetic_diversity : (float * Dna.t) array -> float

(** Print statistics about the given population *)
val print_stats : (float * Dna.t) array -> unit

(** Print the entire population *)
val print_population : (float * Dna.t) array -> unit
