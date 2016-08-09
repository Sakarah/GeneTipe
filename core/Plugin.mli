(** Plugin is the module providing an interface between plugins and the core program.
    The core should call the plugins function through the provided hooks. *)

(** Exception related to the loading of a plugin *)
exception Error of string

(** Loads a plugin executing it. The plugin should register its hooks during its execution. *)
val load : string -> unit


(** Input type for the MakeHookClass functor *)
module type HookType =
sig
    type t (** Data type of the hook to create *)
end

(** Output type for the MakeHookClass functor *)
module type HookClass =
sig
    type t
    val register : string -> t -> unit (** Register a new hook with the specified key *)
    val get : string -> t (** Get the hook corresponding to the given key *)
end

(** Create a new hook class with the type specified.
    A hook class creates an interface between a part of code which use the hooks and the plugin which register them.
    A hook class is associated with the type of the registered hooked values (usually functions). *)
module MakeHookClass (Type : HookType) : HookClass with type t = Type.t

(** {2 Standard hook classes } *)
(** All standard hook class are containing functions taking a JSON tree as their first argument. 
    This is intended to provide constant parameters usually specified in the configuration file to the hooked function. *)

(** Module type of a fitness evaluator. A fitness evaluator describes how to parse the input data and 
    provides a fitness function.  The fitness function should tell how well the given individual match the target data. 
    Bigger output mean better individuals. *)
module type FitnessEvaluator = 
sig
    type individual
    module TargetData : EvolParams.TargetData
    val fitness : TargetData.t -> individual -> float
end

(** Module type of a genetic type. A genetic type contains an individual module that describes the type of individuals that can be evolved and 
    a standard set of hooks for registering genetic operators and functions around this type of individuals. *)
module type GeneticTypeInterface =
sig
    module Individual : EvolParams.Individual
    
    (** Hook class for creation methods. A creation method should build a entirely new individual from scratch not exceeding the given max_depth. *)
    module Creation : HookClass with type t = (Yojson.Basic.json -> pop_frac:float -> Individual.t)

    (** Hook class for mutation operations. A mutation operation should modify the given individual to create a slightly different one not exceeding the given max_depth. *)
    module Mutation : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)

    (** Hook class for crossover operators. Crossovers are suppose to mix the characteristics of two given individual to create a new one. *)
    module Crossover : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)

    (** Hook class for fitness evaluator. See the documentation for FitnessEvaluator for more informations. *)
    module Fitness : HookClass with type t = (Yojson.Basic.json -> (module FitnessEvaluator with type individual = Individual.t))

    (** Hook class for simplification operations. Simplifications are supposed to reduce the complexity of an individual without changing its behavior. *)
    module Simplification : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end

(** Hook class for the genetic types. *)
module GeneticType : HookClass with type t = (module GeneticTypeInterface)

(** Hook class of the random generators. Its functions are taking nothing and must return a random float value. *)
module RandomGen : HookClass with type t = (Yojson.Basic.json -> unit -> float)
