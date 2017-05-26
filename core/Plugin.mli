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
module MakeHookingPoint : functor (Type : HookType) -> HookingPoint with type t = Type.t

(** {2 Standard hooking points}
    Many standard hooking points are containing functions taking a JSON tree as their first argument.
    This is intended to provide constant parameters usually specified in the configuration file to the hooked function. *)

(** Module type containing a hooking points for each type of genetic operator.
    This interface is the standard layout for a module storing all the hooks related to one individual type. *)
module type GeneticHooks =
sig
    module Individual : EvolParams.Individual
    type target_data

    (** Hooking point for creation methods. A creation method should build a entirely new individual from scratch using eventually the target data. pop_frac is a float number indicating the proportion of the already generated population. *)
    module Creation : HookingPoint with type t = (Yojson.Basic.json -> target_data -> pop_frac:float -> Individual.t)

    (** Hooking point for mutation operations. A mutation operation should modify the given individual to create a slightly different one not exceeding the given max_depth. *)
    module Mutation : HookingPoint with type t = (Yojson.Basic.json -> target_data -> Individual.t -> Individual.t)

    (** Hookint point for crossover operators. Crossovers are suppose to mix the characteristics of two given individual to create a new one. *)
    module Crossover : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)

    (** Hooking point for fitness evaluators. The fitness module defines how to compare individuals to see how they match the target data. *)
    module Fitness : HookingPoint with type t = (Yojson.Basic.json -> (module EvolParams.Fitness with type individual = Individual.t and type target_data = target_data))

    (** Hooking point for simplification operations. Simplifications are supposed to reduce the complexity of an individual without changing its behavior. *)
    module Simplification : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end

(** Functor returning a selection function from a fitness module. These functions take a population and reduce it by selecting only a fraction of the individuals contained in it. We are forced to use a functor here to keep the polymorphism. *)
module type SelectionMethod = functor (Fitness : EvolParams.Fitness) -> sig val f:(Fitness.t * 'i) array -> target_size:int -> (Fitness.t * 'i) array end

(** Hooking point for the selection methods. *)
module Selection : HookingPoint with type t = (Yojson.Basic.json -> (module SelectionMethod))

(** Functor returning a parent chooser function from a fitness module. These functions should select one individual from the given list for beeing used as a parent in the reproduction phase. Note that it enables you to generate more than one parent with a single list to potentially save a precomputing task on the list. Same as above for the reasons of declaring a module. *)
module type ParentChooserMethod = functor (Fitness : EvolParams.Fitness) -> sig val f:(Fitness.t * 'i) array -> unit -> 'i end

(** Hooking point for parent choosers. *)
module ParentChooser : HookingPoint with type t = (Yojson.Basic.json -> (module ParentChooserMethod))

(** Hooking point of the random generators. The registered functions are taking nothing and must return a random float value. *)
module RandomGen : HookingPoint with type t = (Yojson.Basic.json -> unit -> float)
