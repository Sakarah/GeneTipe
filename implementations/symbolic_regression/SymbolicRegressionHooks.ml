module Individual = FunctionDna;;
type target_data = (float*float) array;;

module BinOp = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> float -> float -> float) end);;
module UnOp = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> float -> float) end);;
module Creation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> target_data -> pop_frac:float -> FunctionDna.t) end);;
module Mutation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> target_data -> FunctionDna.t -> FunctionDna.t) end);;
module Crossover = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t) end);;
module Fitness = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module EvolParams.Fitness with type individual = FunctionDna.t and type target_data = (float*float) array)) end);;
module Simplification = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t) end);;
