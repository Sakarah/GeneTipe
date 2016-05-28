(** Evolver contains all the functions related to creation and then evolution
    of a population. It implements natural selection mechanics and manage the
    population growth by mutation and crossover. **)

(** Initialize the population with randomly generated individuals **)
val init_population : size:int -> Dna.t array

(** Measure how interesting a function is **)
val fitness : (float*float) array -> Dna.t -> float
(** Organize a fight between functions to discard some of the weakest **)
val tournament : Dna.t array -> Dna.t array

(** Recombine existing individuals and make mutations to create new functions **)
val reproduce : Dna.t array -> Dna.t array

(** Evolve the population with the fixed number of generations **)
val evolve : Dna.t array -> generations:int -> Dna.t array
