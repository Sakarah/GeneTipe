(** This module defines the hooking points needed for evolving function in a symbolic regression context.
    It also defines the GeneticType of the symbolic regression. *)

module BinOp : Plugin.HookingPoint with type t = (Yojson.Basic.json -> float -> float -> float)
module UnOp : Plugin.HookingPoint with type t = (Yojson.Basic.json -> float -> float)
module Creation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> pop_frac:float -> FunctionDna.t)
module Mutation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t)
module Crossover : Plugin.HookingPoint with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t)
module Fitness : Plugin.HookingPoint with type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = FunctionDna.t))
module Simplification : Plugin.HookingPoint with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t)
