(** This module defines the hook classes needed for evolving a regular expression from a set of examples.
    It also defines the associated GeneticType. *)

module Creation : Plugin.HookClass with type t = (Yojson.Basic.json -> pop_frac:float -> RegexpTree.t)
module Mutation : Plugin.HookClass with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t)
module Crossover : Plugin.HookClass with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t)
module Fitness : Plugin.HookClass with type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = RegexpTree.t))
module Simplification : Plugin.HookClass with type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t)
