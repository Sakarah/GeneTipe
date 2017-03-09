(** This module defines the hooking points needed for evolving a regular expression from a set of examples. *)

module Individual : EvolParams.Individual with type t = RegexpTree.t
type target_data = ExampleList.t

module Creation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> ExampleList.t -> pop_frac:float -> RegexpTree.t)
module Mutation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> RegexpTree.t)
module Crossover : Plugin.HookingPoint with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t)
module Fitness : Plugin.HookingPoint with type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> float)
module Simplification : Plugin.HookingPoint with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t)
