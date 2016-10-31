module Creation = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> pop_frac:float -> RegexpTree.t) end);;
module Mutation = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;
module Crossover = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t) end);;
module Fitness = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> (module Plugin.FitnessEvaluator with type individual = RegexpTree.t)) end);;
module Simplification = Plugin.MakeHookClass (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;

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
