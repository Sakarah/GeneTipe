(** Plugin is the module providing an interface between plugins and the core program.
    The core should call the plugins function through the provided hooks. *)

(** Exception related to the loading of a plugin *)
exception Error of string

(** Loads a plugin executing it. The plugin should register its hooks during its execution. *)
val load : string -> unit


(** Input type for {!MakeHookingPoint} *)
module type HookType =
sig
    type t (** Data type of the hooks *)
end

(** Output type of {!MakeHookingPoint} *)
module type HookingPoint =
sig
    type t
    val register : string -> t -> unit (** Register a new hook with the specified key *)
    val get : string -> t (** Get the hook corresponding to the given key *)
end

(** Create a new hooking point with the type specified.
    A hooking point creates an interface between a part of code which use the hooks and the plugin which register them.
    A hooking point only allows hooks with the same type (usually functions). *)
module MakeHookingPoint (Type : HookType) : HookingPoint with type t = Type.t

(** {2 Standard hooking points} 
    Many standard hooking points are containing functions taking a JSON tree as their first argument. 
    This is intended to provide constant parameters usually specified in the configuration file to the hooked function. *)

(** Module type of a fitness evaluator. A fitness evaluator describes how to parse the input data and 
    provides a fitness function. The fitness function should tell how well the given individual match the target data. 
    Bigger output mean better individuals. *)
module type FitnessEvaluator = 
sig
    type individual
    module TargetData : EvolParams.TargetData
    val fitness : TargetData.t -> individual -> float
end

(** Module type of a genetic type. A genetic type contains an individual module that describes the type of individuals that can be evolved and 
    a standard set of hooking points for registering genetic operators and functions around this type of individuals. *)
module type GeneticTypeInterface =
sig
    module Individual : EvolParams.Individual
    
    (** Hooking point for creation methods. A creation method should build a entirely new individual from scratch not exceeding the given max_depth. *)
    module Creation : HookingPoint with type t = (Yojson.Basic.json -> pop_frac:float -> Individual.t)

    (** Hooking point for mutation operations. A mutation operation should modify the given individual to create a slightly different one not exceeding the given max_depth. *)
    module Mutation : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)

    (** Hookint point for crossover operators. Crossovers are suppose to mix the characteristics of two given individual to create a new one. *)
    module Crossover : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)

    (** Hooking point for fitness evaluator. See the documentation for FitnessEvaluator for more informations. *)
    module Fitness : HookingPoint with type t = (Yojson.Basic.json -> (module FitnessEvaluator with type individual = Individual.t))

    (** Hooking point for simplification operations. Simplifications are supposed to reduce the complexity of an individual without changing its behavior. *)
    module Simplification : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end

(** Hooking point for the genetic types. *)
module GeneticType : HookingPoint with type t = (module GeneticTypeInterface)

(** Hooking point of the random generators. The registered functions are taking nothing and must return a random float value. *)
module RandomGen : HookingPoint with type t = (Yojson.Basic.json -> unit -> float)
