(** Evolver contains all the functions related to creation and then evolution
    of a population. It implements natural selection mechanics and manage the
    population growth by mutation and crossover.
    You can create a new evolver from any EvolParams module using {!Make}. *)

(** Module signature of an evolver *)
module type S =
sig
    (** Type of the evolved individuals *)
    type individual

    (** Type of the target data*)
    type target_data

    (** Initialize the population with randomly generated individuals *)
    val init_population : target_data -> (float option * individual) array

    (** Compute the fitness of all the individuals of a population *)
    val compute_fitness : target_data -> (float option * individual) array -> (float * individual) array

    (** Simplify all the individuals from the given population *)
    val simplify_individuals : ?generation:int -> (float * individual) array -> (float * individual) array

    (** Recombine existing individuals and make mutations to create new functions *)
    val reproduce : target_data -> (float * individual) array -> (float option * individual) array

    (** Filter the input population to reach the given size by using the selection function *)
    val select : (float * individual) array -> target_size:int -> (float * individual) array

    (** Replace duplicates by new randomly generated individuals *)
    val remove_duplicate : target_data -> (float option * individual) array -> (float option * individual) array

    (** Evolve the population with the fixed number of generations *)
    val evolve : target_data -> (float * individual) array -> (float * individual) array
end

(** Create a new Evolver from the given parameters *)
module Make : functor (Parameters : EvolParams.S) -> S with type individual := Parameters.Individual.t and type target_data := Parameters.TargetData.t
