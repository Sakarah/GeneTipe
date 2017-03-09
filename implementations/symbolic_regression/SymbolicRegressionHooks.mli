(** This module defines the hooking points needed for evolving function in a symbolic regression context. *)

module Individual : EvolParams.Individual with type t = FunctionDna.t
type target_data = (float*float) array;;

module BinOp : Plugin.HookingPoint with type t = (Yojson.Basic.json -> float -> float -> float)
module UnOp : Plugin.HookingPoint with type t = (Yojson.Basic.json -> float -> float)
module Creation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> target_data -> pop_frac:float -> FunctionDna.t)
module Mutation : Plugin.HookingPoint with type t = (Yojson.Basic.json -> target_data -> FunctionDna.t -> FunctionDna.t)
module Crossover : Plugin.HookingPoint with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t)
module Fitness : Plugin.HookingPoint with type t = (Yojson.Basic.json -> target_data -> FunctionDna.t -> float)
module Simplification : Plugin.HookingPoint with type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t)
