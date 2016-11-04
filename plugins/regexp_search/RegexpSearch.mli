(** This module defines the hooking points needed for evolving a regular expression from a set of examples.
    It also defines the associated GeneticType. *)

module Creation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> pop_frac:float -> RegexpTree.t)
module Mutation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t)
module Crossover : Plugin.HookingPoint with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t)
module Fitness : Plugin.HookingPoint with type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = RegexpTree.t))
module Simplification : Plugin.HookingPoint with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t)
