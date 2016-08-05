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

(** Hook class of the random generators. Its functions are taking nothing and must return a random float value. *)
module RandomGen : HookClass with type t = (Yojson.Basic.json -> unit -> float)

(** Hook class for the binary operations in the DNA tree. *)
module BinOp : HookClass with type t = (Yojson.Basic.json -> float -> float -> float)

(** Hook class for the unary operations in the DNA tree. *)
module UnOp : HookClass with type t = (Yojson.Basic.json -> float -> float)

(** Hook class for terminal nodes in the DNA tree. The result of the function is a tuple containing the number of tweakable constant parameters, 
    the string conversion function and the evaluation function (taking the parameters and the input data) *)
module TermNode : HookClass with type t = (Yojson.Basic.json -> (int*(float list->string)*(float list->float->float)))

(** Hook class for creation methods. A creation method should build a entirely new individual from scratch not exceeding the given max_depth. *)
module Creation : HookClass with type t = (Yojson.Basic.json -> max_depth:int -> Dna.t)

(** Hook class for mutation operations. A mutation operation should modify the given Dna source to create a slightly different individual not exceeding the given max_depth. *)
module Mutation : HookClass with type t = (Yojson.Basic.json -> max_depth:int -> Dna.t -> Dna.t)

(** Hook class for crossover operators. Crossovers are suppose to mix the two Dna sources given to create a new individual. *)
module Crossover : HookClass with type t = (Yojson.Basic.json -> Dna.t -> Dna.t -> Dna.t)

(** Hook class for fitness functions. A fitness function should tell how well the given Dna match the data given. Bigger output mean better individuals. *)
module Fitness : HookClass with type t = (Yojson.Basic.json -> (float*float) array -> Dna.t -> float)

(** Hook class for simplification operations. Simplifications are supposed to reduce the given Dna tree without changing its mathematical meaning. *)
module Simplification : HookClass with type t = (Yojson.Basic.json -> Dna.t -> Dna.t)
