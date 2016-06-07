(** This modules give some statistics about a population *)

(** Return the best individual from the population *)
val best_individual : (float * Dna.t) array -> (float * Dna.t)

(** Return the average fitness of the population *)
val average_fitness : (float * Dna.t) array -> float

(** Return the number of branches of the individual *)
val branch_number : Dna.t -> float

(** Return the average depth of the individual*)
val avg_depth : Dna.t -> float

(** Return a measurement of the genetic diversity of the population 
	computes the variance of number of each operator in the population as well as the variance of depth and add them
	Return the standard deviation *)
val genetic_diversity : (float * Dna.t) array -> (float * string * (float -> float -> float)) array -> (float * string * (float -> float)) array -> float

(** Print statistics about the given population *)
val print_stats : (float * Dna.t) array -> unit

(** Print the entire population *)
val print_population : (float * Dna.t) array -> unit
