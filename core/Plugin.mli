(** Plugin is the module providing an interface between plugins and the core program.
    The core should call the plugins function through the provided hooks. *)

(** Exception related to the loading of a plugin *)
exception Error of string

(** Loads a plugin executing it. The plugin should register its hooks during its execution. *)
val load : string -> unit


(** Input type for the MakeHookClass functor *)
module type HookType = sig
    type t (** Data type of the hook to create *)
end

(** Output type for the MakeHookClass functor *)
module type HookClass = sig
    type t
    val register : string -> t -> unit (** Register a new hook with the specified key *)
    val get : string -> t (** Get the hook corresponding to the given key *)
end

(** Create a new hook class with the type specified.
    A hook class creates an interface between a part of code which use the hooks and the plugin which register them.
    A hook class is associated with the type of the registered hooked values (usually functions). *)
module MakeHookClass (Type : HookType) : HookClass with type t = Type.t

(** {2 Standard hook classes } *)
module RandomGen : HookClass with type t = (Yojson.Basic.json -> unit -> float)
module BinOp : HookClass with type t = (Yojson.Basic.json -> float -> float -> float)
module UnOp : HookClass with type t = (Yojson.Basic.json -> float -> float)
module Creation : HookClass with type t = (Yojson.Basic.json -> max_depth:int -> Dna.t)
module Mutation : HookClass with type t = (Yojson.Basic.json -> max_depth:int -> Dna.t -> Dna.t)
module Crossover : HookClass with type t = (Yojson.Basic.json -> Dna.t -> Dna.t -> Dna.t)
module Fitness : HookClass with type t = (Yojson.Basic.json -> (float*float) array -> Dna.t -> float)
module Simplification : HookClass with type t = (Yojson.Basic.json -> Dna.t -> Dna.t)
