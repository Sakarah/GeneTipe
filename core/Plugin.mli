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

(** Module type of a genetic type. A genetic type contains an individual module that describes the type of individuals that can be evolved,
    a target data module that describes how to parse the input data and a standard set of hooking points for registering genetic operators
    and functions around this type of individuals. *)
module type GeneticTypeInterface =
sig
    module Individual : EvolParams.Individual
    module TargetData : EvolParams.TargetData

    (** Hooking point for creation methods. A creation method should build a entirely new individual from scratch not exceeding the given max_depth. *)
    module Creation : HookingPoint with type t = (Yojson.Basic.json -> TargetData.t -> pop_frac:float -> Individual.t)

    (** Hooking point for mutation operations. A mutation operation should modify the given individual to create a slightly different one not exceeding the given max_depth. *)
    module Mutation : HookingPoint with type t = (Yojson.Basic.json -> TargetData.t -> Individual.t -> Individual.t)

    (** Hookint point for crossover operators. Crossovers are suppose to mix the characteristics of two given individual to create a new one. *)
    module Crossover : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)

    (** Hooking point for fitness functions. The fitness function should tell how well the given individual match the target data.
    Bigger output mean better individuals. *)
    module Fitness : HookingPoint with type t = (Yojson.Basic.json -> TargetData.t -> Individual.t -> float)

    (** Hooking point for simplification operations. Simplifications are supposed to reduce the complexity of an individual without changing its behavior. *)
    module Simplification : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end

(** Hooking point for the genetic types. *)
module GeneticType : HookingPoint with type t = (module GeneticTypeInterface)

(** Module containing one selection function. These functions take a population and reduce it by selecting only a fraction of the individuals contained in it. We are forced to use a module here to keep the polymorphism. *)
module type SelectionFunction = sig val f:(float * 'i) array -> target_size:int -> (float * 'i) array end

(** Hooking point for the selection functions. *)
module Selection : HookingPoint with type t = (Yojson.Basic.json -> (module SelectionFunction))

(** Module containing one parent chooser function. These functions should select one individual from the given list for beeing used as a parent in the reproduction phase. Note that it enables you to generate more than one parent with a single list to potentially save a precomputing task on the list. Same as above for the reasons of declaring a module. *)
module type ParentChooserFunction = sig val f:(float * 'i) array -> unit -> 'i end

(** Hooking point for parent choosers. *)
module ParentChooser : HookingPoint with type t = (Yojson.Basic.json -> (module ParentChooserFunction))

(** Hooking point of the random generators. The registered functions are taking nothing and must return a random float value. *)
module RandomGen : HookingPoint with type t = (Yojson.Basic.json -> unit -> float)
