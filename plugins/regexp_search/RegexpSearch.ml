module Creation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> pop_frac:float -> RegexpTree.t) end);;
module Mutation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;
module Crossover = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t) end);;
module Fitness = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = RegexpTree.t)) end);;
module Simplification = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;

let () =
    Plugin.GeneticType.register "regexp_search"
    (module struct
        module Individual = RegexpDna;;
        module Creation = Creation;;
        module Mutation = Mutation;;
        module Crossover = Crossover;;
        module Fitness = Fitness;;
        module Simplification = Simplification;;
    end : Plugin.GeneticTypeInterface)
;;
