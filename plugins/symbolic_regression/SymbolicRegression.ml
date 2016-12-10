module BinOp = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> float -> float -> float) end);;
module UnOp = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> float -> float) end);;
module Creation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> PointSet.t -> pop_frac:float -> FunctionDna.t) end);;
module Mutation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> PointSet.t -> FunctionDna.t -> FunctionDna.t) end);;
module Crossover = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t) end);;
module Fitness = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> PointSet.t -> FunctionDna.t -> float) end);;
module Simplification = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t) end);;

let () =
    Plugin.GeneticType.register "symbolic_regression"
    (module struct
        module Individual = FunctionDna;;
        module TargetData = PointSet;;
        module Creation = Creation;;
        module Mutation = Mutation;;
        module Crossover = Crossover;;
        module Fitness = Fitness;;
        module Simplification = Simplification;;
    end : Plugin.GeneticTypeInterface)
;;
