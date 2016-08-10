(** This module defines the hook classes needed for evolving function in a symbolic regression context.
    It also defines the GeneticType of the symbolic regression. *)

module BinOp : Plugin.HookClass with type t = (Yojson.Basic.json -> float -> float -> float)
module UnOp : Plugin.HookClass with type t = (Yojson.Basic.json -> float -> float)
module Creation : Plugin.HookClass with type t = (Yojson.Basic.json -> pop_frac:float -> FunctionDna.t)
module Mutation : Plugin.HookClass with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t)
module Crossover : Plugin.HookClass with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t)
module Fitness : Plugin.HookClass with type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = FunctionDna.t))
module Simplification : Plugin.HookClass with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t)