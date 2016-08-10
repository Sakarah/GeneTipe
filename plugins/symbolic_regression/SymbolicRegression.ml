module BinOp = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float -> float) end);;
module UnOp = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float) end);;
module Creation = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> pop_frac:float -> FunctionDna.t) end);;
module Mutation = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t) end);;
module Crossover = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t -> FunctionDna.t) end);;
module Fitness = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = FunctionDna.t)) end);;
module Simplification = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> FunctionDna.t -> FunctionDna.t) end);;

let () =
    Plugin.GeneticType.register "symbolic_regression"
    (module struct
        module Individual = FunctionDna;;
        module Creation = Creation;;
        module Mutation = Mutation;;
        module Crossover = Crossover;;
        module Fitness = Fitness;;
        module Simplification = Simplification;;
    end : Plugin.GeneticTypeInterface)
;;