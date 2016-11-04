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
    val init_population : unit -> (float option * individual) array

    (** Compute the fitness of all the individuals of a population *)
    val compute_fitness : target_data -> (float option * individual) array -> (float * individual) array

    (** Simplify all the individuals from the given population *)
    val simplify_individuals : ?generation:int -> (float * individual) array -> (float * individual) array

    (** Organize a fight between functions to discard some of the weakest
        @param target_size Size of the resulting population, it mustn't be greater than the input population size.
        Caution: target_size mustn't be less than half the input population size in this tournament *)
    val tournament : (float * individual) array -> target_size:int -> (float * individual) array

    (** Select the individuals to be copied for the next generation and crossovers by organizing fights between random packs of individuals
        @param target_size Size of the resulting population, it mustn't be greater than the input population size *)
    val tournament_by_packs : (float * individual) array -> target_size:int -> (float * individual) array

    (** Recombine existing individuals and make mutations to create new functions *)
    val reproduce : (float * individual) array -> (float option * individual) array

    (** Replace duplicates by new randomly generated individuals *)
    val remove_duplicate : (float option * individual) array -> (float option * individual) array

    (** Evolve the population with the fixed number of generations *)
    val evolve : target_data -> (float * individual) array -> (float * individual) array
end

(** Create a new Evolver from the given parameters *)
module Make : functor (Parameters : EvolParams.S) -> S with type individual := Parameters.Individual.t and type target_data := Parameters.TargetData.t
